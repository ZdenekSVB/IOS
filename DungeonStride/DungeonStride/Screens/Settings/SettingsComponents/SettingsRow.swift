//
//  SettingsRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String = ""
    var color: Color? = nil // Možnost přepsat barvu ikony
    var showExternalIcon: Bool = false
    
    @ObservedObject var themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                
                // Pokud je to čistý Button a ne NavigationLink, často chceme šipku jen pro externí akce,
                // ale v SettingsRow ji obvykle nedáváme, pokud to není přechod.
                // Pro sjednocení designu ji zde vynechávám, nebo můžeme přidat parametr.
            }
            .padding()
            .background(themeManager.cardBackgroundColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
