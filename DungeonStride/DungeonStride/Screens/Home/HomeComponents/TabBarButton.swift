//
//  TabBarButton.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let title: LocalizedStringKey // Změna na LocalizedStringKey
    let isSelected: Bool
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? themeManager.accentColor : themeManager.secondaryTextColor)
                
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? themeManager.accentColor : themeManager.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
