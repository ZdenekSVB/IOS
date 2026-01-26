//
//  SettingsToggleRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    var hapticsEnabled: Bool = true
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.accentColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(themeManager.primaryTextColor)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                .onChange(of: isOn) { _, _ in
                    HapticManager.shared.lightImpact(enabled: hapticsEnabled)
                }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
    }
}
