//
//  SettingsPreferencesSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsPreferencesSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        SettingsSection(title: "PREFERENCES", themeManager: themeManager) {
            
            SettingsToggleRow(
                icon: "bell.fill",
                title: "Push Notifications", // Lokalizace
                isOn: $viewModel.notificationsEnabled,
                hapticsEnabled: viewModel.hapticsEnabled,
                themeManager: themeManager
            )
            .onChange(of: viewModel.notificationsEnabled) { _, _ in viewModel.updateSettings() }
            
            SettingsToggleRow(
                icon: "speaker.wave.2.fill",
                title: "Sound Effects", // Lokalizace
                isOn: $viewModel.soundEffects,
                hapticsEnabled: viewModel.hapticsEnabled,
                themeManager: themeManager
            )
            .onChange(of: viewModel.soundEffects) { _, _ in viewModel.updateSettings() }
            
            SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                title: "Haptic Feedback", // Lokalizace
                isOn: $viewModel.hapticsEnabled,
                hapticsEnabled: true, // Vždy vibrovat při změně tohoto nastavení (feedback)
                themeManager: themeManager
            )
            .onChange(of: viewModel.hapticsEnabled) { _, _ in viewModel.updateSettings() }
            
            SettingsToggleRow(
                icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill",
                title: "Dark Mode", // Lokalizace
                isOn: Binding(
                    get: { themeManager.isDarkMode },
                    set: { _ in viewModel.toggleDarkMode() }
                ),
                hapticsEnabled: viewModel.hapticsEnabled,
                themeManager: themeManager
            )
            
            UnitPickerRow(
                selectedUnit: $viewModel.selectedUnit,
                hapticsEnabled: viewModel.hapticsEnabled,
                themeManager: themeManager,
                onUpdate: { viewModel.updateSettings() }
            )
        }
    }
}
