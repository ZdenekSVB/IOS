//
//  EquipSlotCell.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct EquipSlotCell: View {
    let slot: EquipSlot
    let item: AItem?
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Prázdný slot
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackgroundColor)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            if let item = item {
                // Pokud je item nasazen, použijeme naši unifikovanou ikonu
                ItemIconView(item: item, size: 60)
            } else {
                // Placeholder
                Image(systemName: slot.placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .foregroundColor(themeManager.secondaryTextColor.opacity(0.3))
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
}
