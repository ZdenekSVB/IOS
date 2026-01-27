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
    
    var canAfford: Bool { userCoins >= slot.price }
    
    var body: some View {
        VStack {
            Text(item.name)
                .font(.caption).bold()
                .lineLimit(1)
                .padding(.top, 10)
                .padding(.horizontal, 5)
            
            ZStack {
                Image(systemName: "cube.box.fill") // Placeholder, pokud nemáš assety
                    .resizable().frame(width: 40, height: 40)
                    .foregroundColor(item.rarity?.color ?? .gray)
                    .opacity(slot.isPurchased ? 0.3 : 1.0)
                
                if slot.isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable().frame(width: 30, height: 30)
                        .foregroundColor(.green)
                }
            }
            .frame(height: 50)
            
            // Fixní prostor pro tlačítko/text
            ZStack {
                if slot.isPurchased {
                    Text("SOLD OUT")
                        .font(.caption2).bold()
                        .foregroundColor(.gray)
                } else {
                    Button(action: {
                        if canAfford {
                            HapticManager.shared.success()
                            SoundManager.shared.playSystemSuccess()
                            onBuy()
                        } else {
                            HapticManager.shared.error()
                        }
                    }) {
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
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .frame(height: 40) // Rezervujeme místo pro tlačítko
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.rarity?.color.opacity(0.5) ?? .gray, lineWidth: 1)
        )
        // DŮLEŽITÉ: Fixní výška celé buňky, aby neskákala
        .frame(height: 140)
    }
}
