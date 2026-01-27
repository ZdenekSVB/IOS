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
    
    @EnvironmentObject var themeManager: ThemeManager // Použijeme themeManager
    
    var canAfford: Bool { userCoins >= slot.price }
    
    var body: some View {
        VStack(spacing: 0) {
            // HORNÍ ČÁST: Obrázek
            ZStack {
                Color.clear
                
                if item.isSystemIcon {
                    Image(systemName: item.iconName)
                        .resizable()
                        .scaledToFit()
                        .padding(15)
                        .foregroundColor(item.rarity?.color ?? .gray)
                } else {
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                }
                
                if slot.isPurchased {
                    Color.black.opacity(0.6)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .shadow(radius: 5)
                }
            }
            .frame(height: 80)
            .background(themeManager.backgroundColor.opacity(0.3)) // Jemné podbarvení
            
            // DOLNÍ ČÁST: Info
            VStack(spacing: 4) {
                Text(item.name)
                    .font(.caption2).bold()
                    .lineLimit(1)
                    .foregroundColor(themeManager.primaryTextColor)
                
                if slot.isPurchased {
                    Text("OWNED")
                        .font(.caption).bold()
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(.vertical, 4)
                } else {
                    HStack(spacing: 2) {
                        Text("\(slot.price)")
                        Image(systemName: "dollarsign.circle.fill")
                    }
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(canAfford ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(canAfford ? .green : .red)
                    .cornerRadius(6)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(themeManager.cardBackgroundColor) // Barva karty z tématu
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.rarity?.color.opacity(0.6) ?? themeManager.secondaryTextColor.opacity(0.2), lineWidth: 2)
        )
        .frame(height: 140)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
