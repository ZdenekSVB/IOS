//
//  SettingsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//  OPRAVA: child views používají @ObservedObject themeManager, aby reagovaly na změny
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEffects = true
    @State private var selectedUnit: DistanceUnit = .metric
    @EnvironmentObject var themeManager: ThemeManager // ← PŘIDÁNO jako EnvironmentObject
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel

    
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
                        
                        // MARK: - APP SETTINGS
                        SettingsSection(title: "APP SETTINGS", themeManager: themeManager) {
                            SettingsToggleRow(
                                icon: "bell.fill",
                                title: "Push Notifications",
                                isOn: $notificationsEnabled,
                                themeManager: themeManager
                            )
                            .onChange(of: notificationsEnabled) { _, _ in updateSettingsInFirestore() }

                            SettingsToggleRow(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                isOn: $soundEffects,
                                themeManager: themeManager
                            )
                            .onChange(of: soundEffects) { _, _ in updateSettingsInFirestore() }

                            SettingsToggleRow(
                                icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill",
                                title: "Dark Mode",
                                isOn: Binding(
                                    get: { themeManager.isDarkMode },
                                    set: { newValue in
                                        if newValue != themeManager.isDarkMode {
                                            themeManager.toggleDarkMode()
                                            updateSettingsInFirestore()
                                        }
                                    }
                                ),
                                themeManager: themeManager
                            )

                            // 💡 Přidaný Picker pro jednotky
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(themeManager.accentColor)
                                    .frame(width: 30)
                                
                                Text("Units")
                                    .foregroundColor(themeManager.primaryTextColor)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Picker("", selection: $selectedUnit) {
                                    ForEach(DistanceUnit.allCases, id: \.self) { unit in
                                        Text(unit.displayName).tag(unit)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: selectedUnit) { _, _ in
                                    updateSettingsInFirestore()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(themeManager.cardBackgroundColor)
                            .cornerRadius(12)
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
            
        }.onAppear {
            if let user = userService.currentUser {
                notificationsEnabled = user.settings.notificationsEnabled
                soundEffects = user.settings.soundEffectsEnabled
                selectedUnit = user.settings.units
            }
            
        }
        
    }
    private func updateSettingsInFirestore() {
        guard let uid = authViewModel.currentUserUID else { return }

        let newSettings = UserSettings(
            isDarkMode: themeManager.isDarkMode,
            notificationsEnabled: notificationsEnabled,
            soundEffectsEnabled: soundEffects,
            units: selectedUnit
        )


        Task {
            do {
                try await userService.updateUserSettings(uid: uid, settings: newSettings)
                print("✅ Settings updated in Firestore: \(newSettings)")
            } catch {
                print("❌ Failed to update settings: \(error.localizedDescription)")
            }
        }
    }

}

// MARK: - Settings Components s podporou témat
struct SettingsSection<Content: View>: View {
    let title: String
    @ObservedObject var themeManager: ThemeManager
    let content: Content
    
    init(title: String, themeManager: ThemeManager, @ViewBuilder content: () -> Content) {
        self.title = title
        self._themeManager = ObservedObject(wrappedValue: themeManager)
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
    
    init(icon: String, title: String, value: String, themeManager: ThemeManager, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.value = value
        self._themeManager = ObservedObject(wrappedValue: themeManager)
        self.action = action
    }
    
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
        // odstraněno default button style interference, pokud chcete můžete přidat .buttonStyle(PlainButtonStyle())
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    @ObservedObject var themeManager: ThemeManager
    
    init(icon: String, title: String, isOn: Binding<Bool>, themeManager: ThemeManager) {
        self.icon = icon
        self.title = title
        self._isOn = isOn
        self._themeManager = ObservedObject(wrappedValue: themeManager)
    }
    
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
