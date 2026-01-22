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
        _viewModel = StateObject(wrappedValue: SettingsViewModel(userService: UserService(), authViewModel: AuthViewModel(), themeManager: ThemeManager()))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // --- PROFILE & ACCOUNT ---
                        SettingsSection(title: "ACCOUNT", themeManager: themeManager) {
                            if let user = userService.currentUser {
                                NavigationLink(destination: EditProfileView(
                                    viewModel: EditProfileViewModel(
                                        user: user,
                                        userService: userService,
                                        authViewModel: authViewModel
                                    )
                                )) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                            .foregroundColor(themeManager.accentColor)
                                            .frame(width: 30)
                                        Text("Edit Profile & Security")
                                            .foregroundColor(themeManager.primaryTextColor)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                    .padding()
                                    .background(themeManager.cardBackgroundColor)
                                }
                            }
                        }
                        
                        // --- APP SETTINGS ---
                        SettingsSection(title: "PREFERENCES", themeManager: themeManager) {
                            
                            SettingsToggleRow(icon: "bell.fill", title: "Push Notifications", isOn: $viewModel.notificationsEnabled, themeManager: themeManager)
                                .onChange(of: viewModel.notificationsEnabled) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: "speaker.wave.2.fill", title: "Sound Effects", isOn: $viewModel.soundEffects, themeManager: themeManager)
                                .onChange(of: viewModel.soundEffects) { _, _ in viewModel.updateSettings() }
                            
                            // NOVÉ: Haptika
                            SettingsToggleRow(icon: "iphone.radiowaves.left.and.right", title: "Haptic Feedback", isOn: $viewModel.hapticsEnabled, themeManager: themeManager)
                                .onChange(of: viewModel.hapticsEnabled) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill", title: "Dark Mode", isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in viewModel.toggleDarkMode() }
                            ), themeManager: themeManager)
                            
                            unitPickerRow
                        }
                        
                        // --- SUPPORT (Funkční odkazy) ---
                        SettingsSection(title: "SUPPORT", themeManager: themeManager) {
                            // Tyto URL si časem nahraď svými reálnými
                            SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", value: "", themeManager: themeManager) {
                                viewModel.openUrl("https://www.google.com") // Doplň real URL
                            }
                            
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", value: "", themeManager: themeManager) {
                                viewModel.openUrl("https://www.google.com") // Doplň real URL
                            }
                            
                            SettingsRow(icon: "envelope.fill", title: "Contact Support", value: "", themeManager: themeManager) {
                                viewModel.sendEmail()
                            }
                        }
                        
                        // --- DANGER ZONE & LOGOUT ---
                        VStack(spacing: 12) {
                            Button(action: {
                                viewModel.logout()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Log Out")
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
                                viewModel.showDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Delete Account")
                                }
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                                .padding(8)
                            }
                        }
                        .padding(.top, 10)
                        
                        // --- VERSION ---
                        Text("Version \(viewModel.appVersion)")
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
                            .padding(.bottom, 20)
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
            // Alert pro smazání účtu
            .alert("Delete Account?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount()
                }
            } message: {
                Text("This action cannot be undone. All your progress, items, and stats will be permanently lost.")
            }
            // Alert pro chybu při mazání
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
