//
//  InventoryItemCell.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct InventoryItemCell: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Pozadí
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                
                // Obrázek
                if item.item.isSystemIcon {
                    Image(systemName: item.item.iconName)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .foregroundColor(item.item.rarity?.color ?? .gray)
                } else {
                    Image(item.item.iconName)
                        .resizable()
                        .scaledToFit()
                        // Žádný padding pro assety
                }
                
                // Rámeček rarity
                RoundedRectangle(cornerRadius: 12)
                    .stroke(item.item.rarity?.color ?? .gray, lineWidth: 2)
                
                // Počet kusů
                if item.quantity > 1 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(item.quantity)")
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.gray.opacity(0.9)))
                                .offset(x: 5, y: 5)
                        }
                    }
                    .padding(4)
                }
            }
            .frame(width: 70, height: 70)
            
            // Jméno pod obrázkem
            Text(item.item.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 75)
                .padding(.top, 4)
        }
    }
}
