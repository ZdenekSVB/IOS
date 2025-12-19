//
//  CharacterView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 19.12.2025.
//
import SwiftUI

struct CharacterView: View {
    @StateObject var charVM = CharacterViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                // Hlavní obsah oddělený do funkce pro odlehčení kompilátoru
                mainContent
            }
            .navigationTitle(charVM.user?.username ?? "Hrdina")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill").foregroundColor(.yellow)
                        Text("\(charVM.user?.coins ?? 0)")
                            .font(.headline)
                    }
                }
            }
            // LOGIKA NAČÍTÁNÍ
            .onAppear {
                if let uid = authVM.currentUserUID {
                    charVM.fetchData(for: uid)
                }
            }
            .onChange(of: authVM.currentUserUID) { newUid in
                if let uid = newUid {
                    charVM.fetchData(for: uid)
                } else {
                    charVM.stopListening()
                }
            }
            // MODAL 1: POROVNÁNÍ (Batoh -> Equip)
            .sheet(item: $charVM.selectedItemForCompare) { invItem in
                // Bezpečně rozbalíme slot
                if let slot = invItem.item.computedSlot {
                    ComparisonView(
                        newItem: invItem.item,
                        currentItem: charVM.getEquippedItem(for: slot),
                        onEquip: {
                            charVM.equipItem(invItem)
                        }
                    )
                }
            }
            // MODAL 2: SUNDÁNÍ (Equip -> Batoh/Nic)
            .sheet(item: $charVM.selectedEquippedSlot) { slot in
                if let item = charVM.getEquippedItem(for: slot) {
                    UnequipSheet(item: item) {
                        charVM.unequipItem(slot: slot)
                    }
                }
            }
        }
    }
    
    // MARK: - Extrahovaný obsah (řeší chybu kompilátoru)
    @ViewBuilder
    var mainContent: some View {
        if charVM.user == nil {
            if authVM.currentUserUID == nil {
                Text("Nejste přihlášeni.")
            } else {
                ProgressView("Načítám hrdinu...")
            }
        } else {
            VStack(spacing: 0) {
                // 1. POSTAVA A SLOTY
                CharacterEquipView(vm: charVM)
                    .padding(.top, 10)
                
                // 2. PŘEPÍNAČ
                Picker("Menu", selection: $charVM.showInventory) {
                    Text("Statistiky").tag(false)
                    Text("Batoh").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
                // 3. OBSAH (Stats nebo Inventory)
                if charVM.showInventory {
                    InventoryGridView(items: charVM.inventoryItems) { item in
                        // Kliknutí na item v batohu
                        if item.item.computedSlot != nil {
                            charVM.selectedItemForCompare = item
                        }
                    }
                } else {
                    if let user = charVM.user {
                        StatsView(user: user) { statName, cost in
                            charVM.upgradeStat(statName, cost: cost)
                        }
                    }
                }
            }
        }
    }
}
// MARK: - Subviews

struct CharacterEquipView: View {
    @ObservedObject var vm: CharacterViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            
            // LEVÝ SLOUPEC (Hlava, Tělo, Ruce, Nohy)
            VStack(spacing: 15) {
                slotCell(.head)
                slotCell(.chest)
                slotCell(.hands)
                slotCell(.legs)
            }
            
            // PROSTŘEDEK (Avatar)
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .foregroundColor(.gray)
                }
                
                Text("Level \(vm.user?.level ?? 1)")
                    .font(.caption)
                    .bold()
                    .padding(4)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(5)
            }
            
            // PRAVÝ SLOUPEC (Zbraň, Štít, Boty)
            VStack(spacing: 15) {
                slotCell(.mainHand)
                slotCell(.offHand)
                slotCell(.feet)
                Spacer().frame(width: 55, height: 55)
            }
        }
        .padding()
    }
    
    // Pomocná funkce pro vytvoření klikatelné buňky
    func slotCell(_ slot: EquipSlot) -> some View {
        EquipSlotCell(slot: slot, item: vm.getEquippedItem(for: slot))
            .onTapGesture {
                // Pokud je ve slotu item, otevřeme detail pro sundání
                if vm.getEquippedItem(for: slot) != nil {
                    vm.selectedEquippedSlot = slot
                }
            }
    }
}

struct EquipSlotCell: View {
    let slot: EquipSlot
    let item: AItem?
    
    var body: some View {
        ZStack {
            // Rámeček
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(width: 55, height: 55)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item?.rarity?.color ?? Color.gray.opacity(0.3), lineWidth: item == nil ? 1 : 2)
                )
            
            // Ikona
            if let item = item {
                Image(systemName: "cube.box.fill") // Zde pak dej Image(item.iconName)
                    .resizable().scaledToFit().frame(width: 30)
                    .foregroundColor(item.rarity?.color ?? .gray)
            } else {
                Image(systemName: slot.placeholderIcon)
                    .resizable().scaledToFit().frame(width: 20)
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
    }
}

// MARK: - Stats View

struct StatsView: View {
    let user: User
    // Callback pro upgrade (statName, cost)
    let onUpgrade: (String, Int) -> Void
    
    var body: some View {
        List {
            let cost = 100 // Cena za upgrade (můžeš dynamicky vypočítat)
            
            // Pozor: Jména statů ("physicalDamage") musí sedět s názvy polí ve Firestore 'stats.physicalDamage'
            StatRow(name: "physicalDamage", title: "Síla", value: user.stats.physicalDamage, cost: cost, icon: "flame.fill", color: .red, userCoins: user.coins, action: onUpgrade)
            
            StatRow(name: "defense", title: "Obrana", value: user.stats.defense, cost: cost, icon: "shield.fill", color: .blue, userCoins: user.coins, action: onUpgrade)
            
            StatRow(name: "magicDamage", title: "Magie", value: user.stats.magicDamage, cost: cost, icon: "sparkles", color: .purple, userCoins: user.coins, action: onUpgrade)
            
            StatRow(name: "maxHP", title: "Vitalita", value: user.stats.maxHP, cost: cost, icon: "heart.fill", color: .green, userCoins: user.coins, action: onUpgrade)
            
            // Jen info řádek (HP Bar)
            Section {
                HStack {
                    Text("Zdraví (HP)")
                    Spacer()
                    Text("\(user.stats.hp) / \(user.stats.maxHP)")
                        .bold()
                }
            }
        }
    }
}

struct StatRow: View {
    let name: String
    let title: String
    let value: Int
    let cost: Int
    let icon: String
    let color: Color
    let userCoins: Int
    let action: (String, Int) -> Void
    
    var body: some View {
        HStack {
            Label { Text(title) } icon: { Image(systemName: icon).foregroundColor(color) }
            Spacer()
            Text("\(value)").bold()
            
            // Tlačítko Upgrade
            Button(action: { action(name, cost) }) {
                HStack(spacing: 2) {
                    Image(systemName: "plus")
                    Text("\(cost)")
                }
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(userCoins >= cost ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(userCoins < cost)
            .buttonStyle(PlainButtonStyle()) // Aby se neklikal celý řádek v Listu
        }
    }
}

// MARK: - Modals (Sheets)

struct ComparisonView: View {
    let newItem: AItem
    let currentItem: AItem?
    let onEquip: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Porovnání Vybavení").font(.headline).padding(.top)
            
            HStack(alignment: .top) {
                // NOVÝ
                VStack {
                    Text("NOVÝ").font(.caption).bold().foregroundColor(.green)
                    ItemDetailCard(item: newItem)
                }
                
                Image(systemName: "arrow.right").padding(.top, 40)
                
                // STARÝ
                VStack {
                    Text("NASAZENO").font(.caption).bold().foregroundColor(.gray)
                    if let current = currentItem {
                        ItemDetailCard(item: current)
                    } else {
                        Text("Prázdné").frame(width: 120, height: 120)
                            .background(Color.gray.opacity(0.1)).cornerRadius(12)
                    }
                }
            }
            
            // Rozdíl statů
            HStack {
                let newAtk = newItem.baseStats.attack ?? 0
                let oldAtk = currentItem?.baseStats.attack ?? 0
                let diff = newAtk - oldAtk
                
                if newAtk > 0 || oldAtk > 0 {
                    Text("Útok: \(newAtk)")
                    if diff != 0 {
                        Text(diff > 0 ? "(+\(diff))" : "(\(diff))")
                            .foregroundColor(diff > 0 ? .green : .red)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                onEquip()
                dismiss()
            }) {
                Text("NASADIT")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
}

struct UnequipSheet: View {
    let item: AItem
    let onUnequip: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(item.name).font(.title3).bold().padding(.top)
            
            ItemDetailCard(item: item)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                onUnequip()
                dismiss()
            }) {
                Label("Sundat (Unequip)", systemImage: "arrow.down.doc.fill")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
}

struct ItemDetailCard: View {
    let item: AItem
    var body: some View {
        VStack {
            Image(systemName: "cube.box.fill")
                .resizable().frame(width: 50, height: 50)
                .foregroundColor(item.rarity?.color ?? .gray)
            Text(item.name)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 2)
            
            Text(item.itemType)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 120, height: 120)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(item.rarity?.color ?? .gray, lineWidth: 2))
    }
}

// MARK: - Inventory Grid

struct InventoryGridView: View {
    let items: [InventoryItem]
    let onItemClick: (InventoryItem) -> Void
    
    let columns = [GridItem(.adaptive(minimum: 70), spacing: 15)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(items) { invItem in
                    InventoryItemCell(item: invItem)
                        .onTapGesture {
                            onItemClick(invItem)
                        }
                }
            }
            .padding()
        }
    }
}

struct InventoryItemCell: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 70, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.item.rarity?.color ?? .gray, lineWidth: 2)
                    )
                
                Image(systemName: "cube.box.fill")
                    .resizable().scaledToFit().frame(width: 40, height: 40)
                    .foregroundColor(item.item.rarity?.color ?? .gray)
                
                if item.quantity > 1 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(item.quantity)")
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.gray))
                                .offset(x: 5, y: 5)
                        }
                    }
                    .padding(5)
                }
            }
            Text(item.item.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 75)
        }
    }
}
