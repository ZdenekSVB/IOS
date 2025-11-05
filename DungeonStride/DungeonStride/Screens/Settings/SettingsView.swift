//
//  SettingsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEffects = true
    @EnvironmentObject var themeManager: ThemeManager // ← PŘIDÁNO
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamické pozadí podle tématu
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Account Settings
                        SettingsSection(title: "ACCOUNT", themeManager: themeManager) {
                            SettingsRow(icon: "person.fill", title: "Edit Profile", value: "", themeManager: themeManager) {
                                // Navigate to edit profile
                            }
                            
                            SettingsRow(icon: "envelope.fill", title: "Email Notifications", value: "", themeManager: themeManager) {
                                // Email settings
                            }
                            
                            SettingsRow(icon: "shield.fill", title: "Privacy", value: "", themeManager: themeManager) {
                                // Privacy settings
                            }
                        }
                        
                        // App Settings
                        SettingsSection(title: "APP SETTINGS", themeManager: themeManager) {
                            SettingsToggleRow(icon: "bell.fill", title: "Push Notifications", isOn: $notificationsEnabled, themeManager: themeManager)
                            
                            SettingsToggleRow(icon: "speaker.wave.2.fill", title: "Sound Effects", isOn: $soundEffects, themeManager: themeManager)
                            
                            // V SettingsView upravte dark mode řádek:
                            SettingsToggleRow(
                                icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill",
                                title: "Dark Mode",
                                isOn: Binding(
                                    get: { themeManager.isDarkMode },
                                    set: { newValue in
                                        // Použijte toggle místo přímého nastavení pro konzistenci
                                        if newValue != themeManager.isDarkMode {
                                            themeManager.toggleDarkMode()
                                        }
                                    }
                                ),
                                themeManager: themeManager
                            )
                            
                            SettingsRow(icon: "chart.bar.fill", title: "Units", value: "Metric", themeManager: themeManager) {
                                // Units settings
                            }
                        }
                        
                        // Support
                        SettingsSection(title: "SUPPORT", themeManager: themeManager) {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", value: "", themeManager: themeManager) {
                                // Help center
                            }
                            
                            SettingsRow(icon: "exclamationmark.triangle.fill", title: "Report a Problem", value: "", themeManager: themeManager) {
                                // Report problem
                            }
                            
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", value: "", themeManager: themeManager) {
                                // Terms of service
                            }
                            
                            SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", value: "", themeManager: themeManager) {
                                // Privacy policy
                            }
                        }
                        
                        // App Info
                        SettingsSection(title: "ABOUT", themeManager: themeManager) {
                            SettingsRow(icon: "info.circle.fill", title: "Version", value: "1.0.0", themeManager: themeManager) {
                                // Version info
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }
}

// MARK: - Settings Components s podporou témat
struct SettingsSection<Content: View>: View {
    let title: String
    let themeManager: ThemeManager
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
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(themeManager.primaryTextColor)
                    .font(.system(size: 16))
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .font(.system(size: 14))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(themeManager.cardBackgroundColor)
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(themeManager.primaryTextColor)
                .font(.system(size: 16))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(themeManager.cardBackgroundColor)
    }
}

