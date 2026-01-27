//
//  SettingsViewModel.swift
//  DungeonStride
//

import Foundation
import Combine
import UIKit

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = true
    @Published var soundEffects: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var selectedUnit: DistanceUnit = .metric
    
    @Published var showDeleteConfirmation = false
    @Published var isDeleting = false
    @Published var deleteError: String?
    
    private var userService: UserService
    private var authViewModel: AuthViewModel
    private var themeManager: ThemeManager
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    init(userService: UserService, authViewModel: AuthViewModel, themeManager: ThemeManager) {
        self.userService = userService
        self.authViewModel = authViewModel
        self.themeManager = themeManager
    }
    
    func synchronize(userService: UserService, authViewModel: AuthViewModel, themeManager: ThemeManager) {
        self.userService = userService
        self.authViewModel = authViewModel
        self.themeManager = themeManager
        
        if let user = userService.currentUser {
            self.notificationsEnabled = user.settings.notificationsEnabled
            self.soundEffects = user.settings.soundEffectsEnabled
            self.hapticsEnabled = user.settings.hapticsEnabled
            self.selectedUnit = user.settings.units
            
            if self.themeManager.isDarkMode != user.settings.isDarkMode {
                self.themeManager.setDarkMode(user.settings.isDarkMode)
            }
        }
    }
    
    func updateSettings() {
        guard let uid = authViewModel.currentUserUID else { return }
        
        // --- LOGIKA NOTIFIKACÍ ---
        if notificationsEnabled {
            NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleDailyNotifications()
        } else {
            NotificationManager.shared.cancelAll()
        }
        // -------------------------
        
        let newSettings = UserSettings(
            isDarkMode: themeManager.isDarkMode,
            notificationsEnabled: notificationsEnabled,
            soundEffectsEnabled: soundEffects,
            hapticsEnabled: hapticsEnabled,
            units: selectedUnit
        )
        
        Task {
            try? await userService.updateUserSettings(uid: uid, settings: newSettings)
        }
    }
    
    func toggleDarkMode() {
        themeManager.toggleDarkMode()
        updateSettings()
    }
    
    func logout() {
        authViewModel.logout()
    }
    
    func deleteAccount() {
        isDeleting = true
        Task {
            do {
                try await authViewModel.deleteAccount()
            } catch {
                deleteError = "Nepodařilo se smazat účet.\nChyba: \(error.localizedDescription)"
                isDeleting = false
            }
        }
    }
    
    func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func sendEmail() {
        let email = "support@dungeonstride.app"
        if let url = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
