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
                Image(systemName: "cube.box.fill").resizable().scaledToFit().frame(width: 30).foregroundColor(item.rarity?.color ?? .gray)
            } else {
                Image(systemName: slot.placeholderIcon).resizable().scaledToFit().frame(width: 20).foregroundColor(.gray.opacity(0.3))
            }
        }
    }
}
