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
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 70, height: 70)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(item.item.rarity?.color ?? .gray, lineWidth: 2))
                
                Image(systemName: "cube.box.fill")
                    .resizable().scaledToFit().frame(width: 40, height: 40)
                    .foregroundColor(item.item.rarity?.color ?? .gray)
                
                if item.quantity > 1 {
                    VStack { Spacer(); HStack { Spacer(); Text("\(item.quantity)").font(.caption2).bold().foregroundColor(.white).padding(4).background(Circle().fill(Color.gray)).offset(x: 5, y: 5) } }.padding(5)
                }
            }
            Text(item.item.name).font(.caption2).lineLimit(1).frame(width: 75)
        }
    }
}
