//
//  ItemDetailCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct ItemDetailCard: View {
    let item: AItem
    var body: some View {
        VStack {
            Image(systemName: "cube.box.fill").resizable().frame(width: 50, height: 50).foregroundColor(item.rarity?.color ?? .gray)
            Text(item.name).font(.caption).bold().multilineTextAlignment(.center).padding(.horizontal, 2)
            Text(item.itemType).font(.caption2).foregroundColor(.secondary)
        }
        .frame(width: 120, height: 120).background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(item.rarity?.color ?? .gray, lineWidth: 2))
    }
}
