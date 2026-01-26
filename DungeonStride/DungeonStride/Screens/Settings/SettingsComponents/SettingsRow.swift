//
//  SettingsRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: LocalizedStringKey // Změna na LocalizedStringKey
    var value: String = ""
    var color: Color? = nil
    var showExternalIcon: Bool = false
    
    @ObservedObject var themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Přidána haptika a zvuk při kliknutí na řádek (např. odkaz)
            // Ideálně bychom sem měli poslat hapticsEnabled/soundEnabled, ale
            // jelikož SettingsRow je obecný a ThemeManager to nemá,
            // můžeme použít default nebo to nechat bez haptiky,
            // POKUD to není ToggleRow (ten má vlastní).
            // Pro konzistenci s odkazy (Support) zde dáme light impact.
            HapticManager.shared.lightImpact()
            SoundManager.shared.playSystemClick()
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color ?? themeManager.accentColor)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value).foregroundColor(themeManager.secondaryTextColor)
                }
                
                if showExternalIcon {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
                }
            }
            .padding()
            .background(themeManager.cardBackgroundColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
