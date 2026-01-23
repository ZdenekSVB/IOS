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
    
    // URL odkazy
    private let reportProblemURL = URL(string: "https://forms.gle/N6SHg5RRvKrKUpqs6")!
    private let privacyPolicyURL = URL(string: "https://www.apple.com/legal/privacy/en-ww/")!
    
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
                                    // Používáme stejný styling jako u Edit Profile pro konzistenci
                                    customNavigationRow(icon: "person.crop.circle.badge.exclamationmark", title: "Edit Profile & Security", color: themeManager.accentColor)
                                }
                            }
                        }
                        
                        // --- APP SETTINGS ---
                        SettingsSection(title: "PREFERENCES", themeManager: themeManager) {
                            
                            SettingsToggleRow(icon: "bell.fill", title: "Push Notifications", isOn: $viewModel.notificationsEnabled, themeManager: themeManager)
                                .onChange(of: viewModel.notificationsEnabled) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: "speaker.wave.2.fill", title: "Sound Effects", isOn: $viewModel.soundEffects, themeManager: themeManager)
                                .onChange(of: viewModel.soundEffects) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: "iphone.radiowaves.left.and.right", title: "Haptic Feedback", isOn: $viewModel.hapticsEnabled, themeManager: themeManager)
                                .onChange(of: viewModel.hapticsEnabled) { _, _ in viewModel.updateSettings() }
                            
                            SettingsToggleRow(icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill", title: "Dark Mode", isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in viewModel.toggleDarkMode() }
                            ), themeManager: themeManager)
                            
                            unitPickerRow
                        }
                        
                        // --- SUPPORT ---
                        SettingsSection(title: "SUPPORT", themeManager: themeManager) {
                            
                            // 1. Report a Problem (Google Form)
                            Button(action: {
                                UIApplication.shared.open(reportProblemURL)
                            }) {
                                customRowContent(icon: "exclamationmark.bubble.fill", title: "Report a Problem", color: .orange, showChevron: false, showExternalIcon: true)
                            }
                            
                            // 2. Contact Us (Interní View)
                            NavigationLink(destination: ContactUsView()) {
                                customNavigationRow(icon: "envelope.fill", title: "Contact Us", color: .blue)
                            }
                            
                            // 3. Terms of Service (Interní View)
                            NavigationLink(destination: TermsOfServiceView()) {
                                customNavigationRow(icon: "doc.text.fill", title: "Terms of Service", color: themeManager.secondaryTextColor)
                            }

                            // 4. Privacy Policy (Apple odkaz)
                            Button(action: {
                                UIApplication.shared.open(privacyPolicyURL)
                            }) {
                                customRowContent(icon: "hand.raised.fill", title: "Privacy Policy", color: .gray, showChevron: false, showExternalIcon: true)
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
    
    // MARK: - Helper Views pro konzistentní design
    
    // Pro NavigationLinky (s šipkou doprava)
    private func customNavigationRow(icon: String, title: String, color: Color) -> some View {
        customRowContent(icon: icon, title: title, color: color, showChevron: true, showExternalIcon: false)
    }
    
    // Samotný obsah řádku
    private func customRowContent(icon: String, title: String, color: Color, showChevron: Bool, showExternalIcon: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(themeManager.primaryTextColor)
            
            Spacer()
            
            if showExternalIcon {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
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
