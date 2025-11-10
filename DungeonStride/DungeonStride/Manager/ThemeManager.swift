//
//  ThemeManager.swift
//  DungeonStride
//
//  Created by you on 2025.
//  OPRAVA: nic zásadně měněno, ale zachování @Published a updateSystemAppearance
//

import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    private var cancellables = Set<AnyCancellable>()
    private var userService: UserService?
    private var authViewModel: AuthViewModel?
    
    // Barvy pro dark/light mode
    var backgroundColor: Color {
        isDarkMode ? Color("Paleta3") : Color("Paleta6")
    }
    
    var cardBackgroundColor: Color {
        // U light módu použijeme jemné pozadí pro karty
        isDarkMode ? Color("Paleta5") : Color("Paleta4").opacity(0.1)
    }
    
    var primaryTextColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color("Paleta4") : Color("Paleta4").opacity(0.7)
    }
    
    var accentColor: Color {
        Color("Paleta2")
    }
    
    // Uložení nastavení do UserDefaults
    private let darkModeKey = "isDarkMode"
    
    init() {
        // Načíst lokální nastavení
        self.isDarkMode = UserDefaults.standard.object(forKey: darkModeKey) as? Bool ?? true
    }
    
    func setupDependencies(userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
        
        // Nastavit posluchače pro změny dark módu
        setupDarkModeListeners()
        
        // Načíst nastavení z Firestore při přihlášení
        loadDarkModeFromFirestore()
    }
    
    private func setupDarkModeListeners() {
        // Sledovat změny z NotificationCenter
        NotificationCenter.default.publisher(for: .darkModeChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let isDarkMode = notification.userInfo?["isDarkMode"] as? Bool {
                    self?.updateDarkModeLocally(isDarkMode)
                }
            }
            .store(in: &cancellables)
        
        // Sledovat změny přihlášení uživatele
        authViewModel?.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.loadDarkModeFromFirestore()
                } else {
                    self?.stopFirestoreListening()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadDarkModeFromFirestore() {
        guard let userId = authViewModel?.currentUserUID,
              let userService = userService else { return }
        
        // Spustit naslouchání změnám uživatele v reálném čase
        userService.startListeningForUserUpdates(uid: userId)
        
        // Načíst aktuální nastavení
        Task {
            do {
                let user = try await userService.fetchUser(uid: userId)
                self.updateDarkModeLocally(user.settings.isDarkMode)
            } catch {
                print("⚠️ Failed to load dark mode from Firestore: \(error.localizedDescription)")
                // Použijte lokální nastavení jako fallback
            }
        }
    }
    
    private func stopFirestoreListening() {
        userService?.stopListeningForUserUpdates()
    }
    
    func toggleDarkMode() {
        let newDarkMode = !isDarkMode
        
        // Lokální aktualizace
        updateDarkModeLocally(newDarkMode)
        
        // Synchronizace s Firestore
        syncDarkModeWithFirestore(isDarkMode: newDarkMode)
    }
    
    func setDarkMode(_ isDarkMode: Bool) {
        updateDarkModeLocally(isDarkMode)
        syncDarkModeWithFirestore(isDarkMode: isDarkMode)
    }
    
    private func updateDarkModeLocally(_ isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        UserDefaults.standard.set(isDarkMode, forKey: darkModeKey)
        updateSystemAppearance()
    }
    
    private func syncDarkModeWithFirestore(isDarkMode: Bool) {
        guard let userId = authViewModel?.currentUserUID,
              let userService = userService else { return }
        
        Task {
            do {
                try await userService.updateDarkMode(uid: userId, isDarkMode: isDarkMode)
                print("✅ Dark mode synced with Firestore: \(isDarkMode)")
            } catch {
                print("❌ Failed to sync dark mode with Firestore: \(error.localizedDescription)")
                // Můžete přidat opakování nebo lokální cache
            }
        }
    }
    
    private func updateSystemAppearance() {
        // Aktualizace windows tak aby i UIKit based screens reflektovaly změnu
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
