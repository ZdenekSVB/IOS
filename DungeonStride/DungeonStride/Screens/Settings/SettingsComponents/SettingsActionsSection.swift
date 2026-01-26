//
//  SettingsActionsSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsActionsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    // Pro kontrolu nastavení (zvuky/haptika)
    var hapticsEnabled: Bool { viewModel.hapticsEnabled }
    var soundEnabled: Bool { viewModel.soundEffects }
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Haptika a zvuk (odhlášení je "negativní/neutrální" akce, dáme medium nebo light)
                HapticManager.shared.mediumImpact(enabled: hapticsEnabled)
                if soundEnabled { SoundManager.shared.playSystemClick() }
                viewModel.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out") // Lokalizace
                }
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.secondaryTextColor.opacity(0.3), lineWidth: 1)
                )
            }
            
            Button(action: {
                // Haptika (varování)
                HapticManager.shared.warning(enabled: hapticsEnabled)
                if soundEnabled { SoundManager.shared.playSystemClick() }
                viewModel.showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Account") // Lokalizace
                }
                .font(.caption)
                .foregroundColor(.red.opacity(0.8))
                .padding(8)
            }
        }
        .padding(.top, 10)
    }
}
