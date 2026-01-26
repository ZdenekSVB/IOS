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
                        Text("Not logged in.") // Lokalizace
                    } else {
                        ProgressView("Loading hero...") // Lokalizace
                    }
                } else {
                    mainContent
                }
            }
            .navigationTitle(charVM.user?.username ?? "Hero") // Lokalizace fallbacku
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
            .onChange(of: authVM.currentUserUID) { newUid in
                if let uid = newUid { charVM.fetchData(for: uid) }
                else { charVM.stopListening() }
            }
            .sheet(item: $charVM.selectedItemForCompare) { invItem in
                if let slot = invItem.item.computedSlot {
                    ComparisonView(
                        newItem: invItem.item,
                        currentItem: charVM.getEquippedItem(for: slot),
                        onEquip: { charVM.equipItem(invItem) }
                    )
                }
            }
            .sheet(item: $charVM.selectedEquippedSlot) { slot in
                if let item = charVM.getEquippedItem(for: slot) {
                    UnequipSheet(item: item) { charVM.unequipItem(slot: slot) }
                }
            }
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 0) {
            CharacterEquipView(vm: charVM)
                .padding(.top, 10)
            
            // Přepínač s haptikou
            Picker("Menu", selection: $charVM.showInventory) {
                Text("Stats").tag(false) // Lokalizace
                Text("Inventory").tag(true) // Lokalizace
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
