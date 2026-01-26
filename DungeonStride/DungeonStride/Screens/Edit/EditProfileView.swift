//
//  EditProfileView.swift
//  DungeonStride
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: EditProfileViewModel
    
    @State private var showAvatarPicker = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // 1. Sekce: Avatar
                    AvatarSection(
                        selectedAvatar: viewModel.selectedAvatar,
                        accentColor: themeManager.accentColor,
                        onTap: {
                            // Haptika a zvuk při otevření pickeru
                            HapticManager.shared.lightImpact()
                            SoundManager.shared.playSystemClick()
                            showAvatarPicker = true
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // 2. Sekce: Základní info
                        BasicInfoSection(
                            username: $viewModel.username,
                            email: viewModel.email,
                            themeManager: themeManager
                        )
                        
                        Divider()
                            .background(themeManager.secondaryTextColor)
                        
                        // 3. Sekce: Heslo
                        PasswordSection(
                            oldPassword: $viewModel.oldPassword,
                            newPassword: $viewModel.newPassword,
                            confirmPassword: $viewModel.confirmNewPassword,
                            themeManager: themeManager
                        )
                    }
                    .padding(.horizontal)
                    
                    // 4. Sekce: Akce
                    ActionSection(
                        errorMessage: viewModel.errorMessage,
                        isLoading: viewModel.isLoading,
                        accentColor: themeManager.accentColor,
                        onSave: {
                            // Haptika a zvuk při stisku Uložit
                            HapticManager.shared.mediumImpact()
                            SoundManager.shared.playSystemClick()
                            viewModel.saveChanges()
                        }
                    )
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Edit Profile") // Lokalizace
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerSheet(selectedAvatar: $viewModel.selectedAvatar)
                .environmentObject(themeManager)
        }
        .onChange(of: viewModel.saveSuccess) { _, success in
            if success {
                // Úspěch!
                HapticManager.shared.success()
                SoundManager.shared.playSystemSuccess()
                dismiss()
            }
        }
    }
}
