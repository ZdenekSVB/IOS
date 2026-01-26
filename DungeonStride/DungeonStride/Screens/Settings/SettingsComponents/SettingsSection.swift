//
//  SettingsSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    @ObservedObject var themeManager: ThemeManager
    let content: Content
    
    init(title: String, themeManager: ThemeManager, @ViewBuilder content: () -> Content) {
        self.title = title
        self.themeManager = themeManager
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.secondaryTextColor)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(12)
        }
    }
}
