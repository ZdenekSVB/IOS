//
//  LabeledInput.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

// Obal pro input s popiskem nahoře
struct LabeledInput<Content: View>: View {
    let label: String
    var themeManager: ThemeManager
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            content
                .modifier(InputStyle(themeManager: themeManager))
        }
    }
}

