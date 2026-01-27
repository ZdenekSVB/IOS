//
//  InventoryItemCell.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct InventoryItemCell: View {
    let item: InventoryItem
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                ItemIconView(item: item.item, size: 70)
                
                if item.quantity > 1 {
                    Text("\(item.quantity)")
                        .font(.caption2).bold()
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().fill(Color.black.opacity(0.7)))
                        .offset(x: 5, y: 5)
                }
            }
            
            Text(item.item.name)
                .font(.caption2)
                .foregroundColor(themeManager.secondaryTextColor)
                .lineLimit(1)
                .frame(width: 75)
        }
    }
}
