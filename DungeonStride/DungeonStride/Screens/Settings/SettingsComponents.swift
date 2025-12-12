//
//  SettingsSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
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

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    @ObservedObject var themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 30)
                Text(title)
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                if !value.isEmpty {
                    Text(value).foregroundColor(themeManager.secondaryTextColor)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding()
            .background(themeManager.cardBackgroundColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
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
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
    }
}
