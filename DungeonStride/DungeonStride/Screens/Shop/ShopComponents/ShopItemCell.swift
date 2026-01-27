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
    
    var canAfford: Bool { userCoins >= slot.price }
    
    var body: some View {
        VStack(spacing: 0) {
            // HORNÍ ČÁST: Obrázek (roztažený)
            ZStack {
                Color.clear // Placeholder pro pozadí
                
                if item.isSystemIcon {
                    Image(systemName: item.iconName)
                        .resizable()
                        .scaledToFit()
                        .padding(15) // Systémové ikony potřebují trochu místa
                        .foregroundColor(item.rarity?.color ?? .gray)
                } else {
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        // ŽÁDNÝ PADDING - ať to vyplní prostor
                }
                
                // Překryv pokud je koupeno
                if slot.isPurchased {
                    Color.black.opacity(0.6)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .shadow(radius: 5)
                }
            }
            .frame(height: 80) // Fixní výška pro obrázek
            .background(Color.white.opacity(0.05)) // Jemné podbarvení
            
            // DOLNÍ ČÁST: Info
            VStack(spacing: 4) {
                Text(item.name)
                    .font(.caption2).bold()
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if slot.isPurchased {
                    Text("OWNED")
                        .font(.caption).bold()
                        .foregroundColor(.gray)
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
            .background(Color(UIColor.secondarySystemBackground))
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.rarity?.color.opacity(0.6) ?? .gray.opacity(0.3), lineWidth: 2)
        )
        // Pevná celková výška
        .frame(height: 140)
    }
}
