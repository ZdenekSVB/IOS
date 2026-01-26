//
//  SettingsNavigationRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsNavigationRow: View {
    let icon: String
    let title: String
    var color: Color? = nil
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color ?? themeManager.accentColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(themeManager.primaryTextColor)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
    }
}
