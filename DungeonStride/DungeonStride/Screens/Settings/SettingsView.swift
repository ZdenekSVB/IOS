//
//  SettingsView.swift
//  DungeonStride
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            userService: UserService(),
            authViewModel: AuthViewModel(),
            themeManager: ThemeManager()
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Account
                        SettingsAccountSection(viewModel: viewModel)
                        
                        // 2. Preferences
                        SettingsPreferencesSection(viewModel: viewModel)
                        
                        // 3. Support
                        SettingsSupportSection()
                        
                        // 4. Actions (Logout / Delete)
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
            // Inicializace dat
            .onAppear {
                viewModel.synchronize(userService: userService, authViewModel: authViewModel, themeManager: themeManager)
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
