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
