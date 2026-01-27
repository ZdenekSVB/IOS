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
    @EnvironmentObject var themeManager: ThemeManager // Přidáno pro barvy
    
    // Pro zobrazení detailu
    @State private var selectedShopSlot: ShopSlot?
    @State private var showDetailSheet = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pozadí celé obrazovky podle tématu
                themeManager.backgroundColor.ignoresSafeArea()
                
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
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(user.coins >= 50 ? themeManager.accentColor : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 2)
                        }
                        .disabled(user.coins < 50)
                        .padding(.top, -20) // Aby tlačítko "plavalo" přes hranici headeru
                        .padding(.bottom, 10)
                        .zIndex(1) // Aby bylo nad obsahem
                    }
                    
                    if vm.isLoading {
                        Spacer()
                        ProgressView("Opening shop...")
                            .tint(themeManager.accentColor)
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                    } else if vm.slots.isEmpty {
                        Spacer()
                        Text("Shop is empty.")
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(vm.slots) { slot in
                                    if let itemDef = vm.masterItems[slot.itemId] {
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
                            .padding(.bottom, 20)
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
                        Text("\(vm.user?.coins ?? 0)")
                            .font(.headline)
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                }
            }
            .onAppear {
                if let uid = authVM.currentUserUID { vm.fetchData(userId: uid) }
            }
            .sheet(isPresented: $showDetailSheet) {
                if let slot = selectedShopSlot,
                   let item = vm.masterItems[slot.itemId],
                   let user = vm.user {
                    
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
                            ? .viewOnly
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
