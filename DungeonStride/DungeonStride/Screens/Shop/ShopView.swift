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
                        Image(systemName: "dollarsign.circle.fill").foregroundColor(.yellow)
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

// MARK: - Subviews

struct MerchantHeaderView: View {
    let timeToNextReset: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85) // Tmavé pozadí
            
            HStack(spacing: 20) {
                // Ikona obchodníka
                Image(systemName: "person.crop.circle.badge.questionmark.fill") // Nebo "bag.fill"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.yellow)
                    .padding(.leading)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Tajemný Obchodník")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Zboží se mění každých 24 hodin.")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Timer
                    HStack {
                        Image(systemName: "clock")
                        Text("Reset za: \(timeToNextReset)")
                            .monospacedDigit() // Aby čísla neposkakovala
                    }
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.orange)
                    .padding(.top, 5)
                }
                Spacer()
            }
        }
        .frame(height: 120)
    }
}

struct ShopItemCell: View {
    let item: AItem
    let slot: ShopSlot
    let userCoins: Int
    let onBuy: () -> Void
    
    // Máme dost peněz?
    var canAfford: Bool { userCoins >= slot.price }
    
    var body: some View {
        VStack {
            // Název
            Text(item.name)
                .font(.caption)
                .bold()
                .lineLimit(1)
                .padding(.top, 10)
                .padding(.horizontal, 5)
            
            // Ikona
            ZStack {
                if slot.isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable().frame(width: 40, height: 40)
                        .foregroundColor(.green.opacity(0.8))
                } else {
                    Image(systemName: "cube.box.fill") // Placeholder za item.iconName
                        .resizable().frame(width: 40, height: 40)
                        .foregroundColor(item.rarity?.color ?? .gray)
                }
            }
            .frame(height: 50)
            
            // Info
            if slot.isPurchased {
                Text("VYPRODÁNO")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            } else {
                // Cena + Tlačítko
                Button(action: onBuy) {
                    HStack(spacing: 2) {
                        Text("\(slot.price)")
                        Image(systemName: "dollarsign.circle.fill")
                    }
                    .font(.caption).bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(canAfford ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(!canAfford)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        // Rámeček podle rarity
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.rarity?.color.opacity(0.5) ?? .gray, lineWidth: 1)
        )
        // Pokud je koupeno, trochu zprůhlednit
        .opacity(slot.isPurchased ? 0.6 : 1.0)
    }
}
