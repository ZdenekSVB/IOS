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
    
    @EnvironmentObject var themeManager: ThemeManager
    
    let columns = [GridItem(.adaptive(minimum: 75), spacing: 15)]
    
    var body: some View {
        ScrollView {
            if items.isEmpty {
                VStack {
                    Spacer(minLength: 50)
                    Image(systemName: "backpack")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
                        .padding(.bottom, 10)
                    Text("Inventory is empty")
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(items) { invItem in
                        InventoryItemCell(item: invItem)
                            .onTapGesture {
                                HapticManager.shared.lightImpact()
                                SoundManager.shared.playSystemClick()
                                onItemClick(invItem)
                            }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(themeManager.backgroundColor) // Pozadí ScrollView
    }
}
