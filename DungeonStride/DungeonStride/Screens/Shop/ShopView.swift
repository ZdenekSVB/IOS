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
                        .padding(.top, -20) // Přesah do headeru
                        .padding(.bottom, 10)
                    }
                    
                    if vm.isLoading {
                        Spacer(); ProgressView("Opening shop..."); Spacer()
                    } else if vm.slots.isEmpty {
                        Spacer(); Text("Shop is empty.").foregroundColor(.gray); Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(vm.slots) { slot in
                                    if let itemDef = vm.masterItems[slot.itemId] {
                                        ShopItemCell(
                                            item: itemDef,
                                            slot: slot,
                                            userCoins: vm.user?.coins ?? 0,
                                            onBuy: { vm.buyItem(slot: slot) }
                                        )
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
        }
    }
}
