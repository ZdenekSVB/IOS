//
//  InventoryGridView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct InventoryGridView: View {
    let items: [InventoryItem]
    let onItemClick: (InventoryItem) -> Void
    let columns = [GridItem(.adaptive(minimum: 70), spacing: 15)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(items) { invItem in
                    InventoryItemCell(item: invItem)
                        .onTapGesture {
                            // Haptika a zvuk při výběru
                            HapticManager.shared.lightImpact()
                            SoundManager.shared.playSystemClick()
                            onItemClick(invItem)
                        }
                }
            }
            .padding()
        }
    }
}
