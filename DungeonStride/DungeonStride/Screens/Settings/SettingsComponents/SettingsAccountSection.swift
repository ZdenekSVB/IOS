//
//  SettingsAccountSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsAccountSection: View {
    @ObservedObject var viewModel: SettingsViewModel // Potřebujeme ViewModel, ale jen jako ObservedObject
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        SettingsSection(title: "ACCOUNT", themeManager: themeManager) {
            if let user = userService.currentUser {
                NavigationLink(destination: EditProfileView(
                    viewModel: EditProfileViewModel(
                        user: user,
                        userService: userService,
                        authViewModel: authViewModel
                    )
                )) {
                    SettingsNavigationRow(
                        icon: "person.crop.circle.badge.exclamationmark",
                        title: "Edit Profile & Security",
                        color: themeManager.accentColor,
                        themeManager: themeManager
                    )
                }
            }
        }
    }
}
