//
//  ShopView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct ShopView: View {
    @StateObject var vm = ShopViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    
    // Pro zobrazení detailu
    @State private var selectedShopSlot: ShopSlot?
    @State private var showDetailSheet = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    MerchantHeaderView(timeToNextReset: vm.timeToNextReset)
                    
                    // REROLL BUTTON
                    if let user = vm.user {
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            vm.rerollShop()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reroll (50")
                                Image(systemName: "dollarsign.circle.fill").foregroundColor(.yellow)
                                Text(")")
                            }
                            .font(.caption).bold()
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(user.coins >= 50 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 2)
                        }
                        .disabled(user.coins < 50)
                        .padding(.top, -15)
                        .padding(.bottom, 10)
                    }
                    
                    if vm.isLoading {
                        Spacer(); ProgressView("Opening shop..."); Spacer()
                    } else if vm.slots.isEmpty {
                        Spacer(); Text("Shop is empty.").foregroundColor(.gray); Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 15) {
                                // ZDE BYLA CHYBA: Používáme prostý ForEach nad polem struktur
                                // ShopSlot musí být Identifiable (což je)
                                ForEach(vm.slots) { slot in
                                    if let itemDef = vm.masterItems[slot.itemId] {
                                        // Celá buňka je tlačítko pro detail
                                        Button(action: {
                                            self.selectedShopSlot = slot
                                            self.showDetailSheet = true
                                        }) {
                                            ShopItemCell(
                                                item: itemDef,
                                                slot: slot,
                                                userCoins: vm.user?.coins ?? 0
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill").foregroundColor(.yellow)
                        Text("\(vm.user?.coins ?? 0)").font(.headline)
                    }
                }
            }
            .onAppear {
                if let uid = authVM.currentUserUID { vm.fetchData(userId: uid) }
            }
            // ZOBRAZENÍ DETAILU
            .sheet(isPresented: $showDetailSheet) {
                if let slot = selectedShopSlot,
                   let item = vm.masterItems[slot.itemId],
                   let user = vm.user {
                    
                    // Zjistíme, co má uživatel na sobě v tomto slotu
                    // Použijeme bezpečné rozbalení
                    let equippedItem: AItem? = {
                        if let slotType = item.computedSlot,
                           let equippedId = user.equippedIds[slotType.id] {
                            return vm.masterItems[equippedId]
                        }
                        return nil
                    }()
                    
                    ItemDetailSheet(
                        item: item,
                        equippedItem: equippedItem,
                        user: user,
                        mode: slot.isPurchased
                            ? .viewOnly // Pokud koupeno, jen prohlížíme
                            : .buy(price: slot.price, onBuy: {
                                vm.buyItem(slot: slot)
                            })
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
    }
}
