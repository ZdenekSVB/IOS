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
                
                if charVM.user == nil {
                    if authVM.currentUserUID == nil {
                        Text("Not logged in.")
                    } else {
                        ProgressView("Loading hero...")
                    }
                } else {
                    mainContent
                }
            }
            .navigationTitle(charVM.user?.username ?? "Hero")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill").foregroundColor(.yellow)
                        Text("\(charVM.user?.coins ?? 0)").font(.headline)
                    }
                }
            }
            .onAppear {
                if let uid = authVM.currentUserUID { charVM.fetchData(for: uid) }
            }
            .onChange(of: authVM.currentUserUID) { _, newUid in
                if let uid = newUid { charVM.fetchData(for: uid) }
                else { charVM.stopListening() }
            }
            // ZMĚNA: Použití ItemDetailSheet i pro UNEQUIP (kliknutí na slot)
            .sheet(item: $charVM.selectedEquippedSlot) { slot in
                if let item = charVM.getEquippedItem(for: slot), let user = charVM.user {
                    // Pro unequip: item je to, co máme na sobě
                    ItemDetailSheet(
                        item: item,
                        equippedItem: item, // Porovnáváme sami se sebou (rozdíl bude 0 -> -hodnota)
                        user: user,
                        mode: .unequip(onUnequip: {
                            charVM.unequipItem(slot: slot)
                        })
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            // Detail pro předmět v BATOHU (Equip / Sell)
            .sheet(item: $charVM.selectedItemForCompare) { invItem in
                if let slot = invItem.item.computedSlot, let user = charVM.user {
                    
                    let equippedItem = charVM.getEquippedItem(for: slot)
                    
                    ItemDetailSheet(
                        item: invItem.item,
                        equippedItem: equippedItem,
                        user: user,
                        mode: .equip(
                            onEquip: { charVM.equipItem(invItem) },
                            onSell: { charVM.sellItem(item: invItem) },
                            sellPrice: invItem.item.finalSellPrice ?? 10
                        )
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 0) {
            CharacterEquipView(vm: charVM)
                .padding(.top, 10)
            
            Picker("Menu", selection: $charVM.showInventory) {
                Text("Stats").tag(false)
                Text("Inventory").tag(true)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .onChange(of: charVM.showInventory) { _, _ in
                HapticManager.shared.lightImpact()
            }
            
            if charVM.showInventory {
                InventoryGridView(items: charVM.inventoryItems) { item in
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
