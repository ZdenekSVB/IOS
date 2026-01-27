//
//  ShopItemCell.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct ShopItemCell: View {
    let item: AItem
    let slot: ShopSlot
    let userCoins: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var canAfford: Bool { userCoins >= slot.price }
    
    var body: some View {
        // Pokud je koupeno, zobrazíme jen prázdnou "SOLD" buňku
        if slot.isPurchased {
            VStack {
                Spacer()
                Text("SOLD")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
                    .rotationEffect(.degrees(-15))
                Spacer()
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(themeManager.cardBackgroundColor.opacity(0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color.clear) // Klikatelnost
            )
        } else {
            // Standardní buňka
            VStack(spacing: 12) {
                // Ikona
                ItemIconView(item: item, size: 80)
                    .shadow(radius: 4)
                    .padding(.top, 10)
                
                VStack(spacing: 4) {
                    Text(item.name)
                        .font(.caption).bold()
                        .foregroundColor(themeManager.primaryTextColor)
                        .lineLimit(1)
                    
                    // Cena
                    HStack(spacing: 4) {
                        Text("\(slot.price)")
                            .font(.subheadline).bold()
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                    }
                    .foregroundColor(canAfford ? .green : .red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.backgroundColor)
                    .cornerRadius(8)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 4)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
