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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(width: 55, height: 55)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(item?.rarity?.color ?? Color.gray.opacity(0.3), lineWidth: item == nil ? 1 : 2))
            
            if let item = item {
                // LOGIKA IKON: Pokud obsahuje tečku, je to SF Symbol, jinak Asset
                if item.iconName.contains(".") {
                    Image(systemName: item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(item.rarity?.color ?? .gray)
                } else {
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
            } else {
                Image(systemName: slot.placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
    }
}
