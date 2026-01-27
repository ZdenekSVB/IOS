//
//  SettingsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // Environment objekty z hlavní aplikace
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Lokální ViewModel
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        // Inicializujeme ViewModel s DI (Dependency Injection)
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            userService: DIContainer.shared.resolve(),
            authViewModel: AuthViewModel(), // Poznámka: Zde by bylo lepší také použít DI nebo Environment
            themeManager: DIContainer.shared.resolve()
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Account Section (Avatar, Jméno, Email, Heslo)
                        SettingsAccountSection(viewModel: viewModel)
                        
                        // 2. Preferences Section (Dark Mode, Notifikace, Zvuky, Jednotky)
                        SettingsPreferencesSection(viewModel: viewModel)
                        
                        // 3. Support Section (Contact Us, Privacy, Terms)
                        SettingsSupportSection()
                        
                        // 4. Actions Section (Logout, Delete Account)
                        SettingsActionsSection(viewModel: viewModel)
                        
                        // 5. Footer (Version)
                        Text("Version \(viewModel.appVersion)")
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
                            .padding(.bottom, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings") // Lokalizace
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { // Lokalizace
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
            // Synchronizace dat při zobrazení
            .onAppear {
                viewModel.synchronize(
                    userService: userService,
                    authViewModel: authViewModel,
                    themeManager: themeManager
                )
            }
            // Alert pro smazání účtu
            .alert("Delete Account?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { } // Lokalizace
                Button("Delete", role: .destructive) { // Lokalizace
                    HapticManager.shared.warning()
                    viewModel.deleteAccount()
                }
            } message: {
                Text("This action cannot be undone. All your progress, items, and stats will be permanently lost.") // Lokalizace
            }
            // Alert pro chybu
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.deleteError != nil },
                set: { _ in viewModel.deleteError = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.deleteError ?? "Unknown error")
            }
        }
    }
}
