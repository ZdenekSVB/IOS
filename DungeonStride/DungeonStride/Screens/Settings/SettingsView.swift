//
//  SettingsView.swift
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel(userService: UserService(), authViewModel: AuthViewModel(), themeManager: ThemeManager())
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        SettingsSection(title: "ACCOUNT", themeManager: themeManager) {
                            SettingsRow(icon: "person.fill", title: "Edit Profile", value: "", themeManager: themeManager) {}
                            SettingsRow(icon: "envelope.fill", title: "Email Notifications", value: "", themeManager: themeManager) {}
                            SettingsRow(icon: "shield.fill", title: "Privacy", value: "", themeManager: themeManager) {}
                        }
                        
                        SettingsSection(title: "APP SETTINGS", themeManager: themeManager) {
                            
                            SettingsToggleRow(icon: "bell.fill", title: "Push Notifications", isOn: $viewModel.notificationsEnabled, themeManager: themeManager)
                                .onChange(of: viewModel.notificationsEnabled) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: "speaker.wave.2.fill", title: "Sound Effects", isOn: $viewModel.soundEffects, themeManager: themeManager)
                                .onChange(of: viewModel.soundEffects) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill", title: "Dark Mode", isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in viewModel.toggleDarkMode() } // Voláme ViewModel pro změnu
                            ), themeManager: themeManager)
                            
                            unitPickerRow
                        }
                        
                        SettingsSection(title: "SUPPORT", themeManager: themeManager) {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", value: "", themeManager: themeManager) {}
                            SettingsRow(icon: "exclamationmark.triangle.fill", title: "Report a Problem", value: "", themeManager: themeManager) {}
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", value: "", themeManager: themeManager) {}
                            SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", value: "", themeManager: themeManager) {}
                        }
                        
                        SettingsSection(title: "ABOUT", themeManager: themeManager) {
                            SettingsRow(icon: "info.circle.fill", title: "Version", value: "1.0.0", themeManager: themeManager) {}
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .onAppear {
                viewModel.synchronize(userService: userService, authViewModel: authViewModel, themeManager: themeManager)
            }
        }
    }
    
    private var unitPickerRow: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundColor(themeManager.accentColor)
                .frame(width: 30)
            Text("Units")
                .foregroundColor(themeManager.primaryTextColor)
            Spacer()
            Picker("", selection: $viewModel.selectedUnit) {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.selectedUnit) { _, _ in viewModel.updateSettings() }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
    }
}
