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
    
    // Mřížka: 2 sloupce
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- 1. HLAVIČKA OBCHODNÍKA ---
                    MerchantHeaderView(timeToNextReset: vm.timeToNextReset)
                    
                    // --- 2. MŘÍŽKA ZBOŽÍ ---
                    if vm.slots.isEmpty {
                        Spacer()
                        ProgressView("Otevírám obchod...")
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(vm.slots) { slot in
                                    // Zobrazíme jen pokud máme definici itemu
                                    if let itemDef = vm.masterItems[slot.itemId] {
                                        ShopItemCell(
                                            item: itemDef,
                                            slot: slot,
                                            userCoins: vm.user?.coins ?? 0,
                                            onBuy: {
                                                vm.buyItem(slot: slot)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Obchod")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(vm.user?.coins ?? 0)")
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                if let uid = authVM.currentUserUID {
                    vm.fetchData(userId: uid)
                }
            }
        }
    }
}
