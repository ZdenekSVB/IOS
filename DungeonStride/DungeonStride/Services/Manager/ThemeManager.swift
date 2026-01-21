//
//  ThemeManager.swift
//  DungeonStride
//

import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private var userService: UserService?
    private var authViewModel: AuthViewModel?
    private let darkModeKey = "isDarkMode"
    
    // MARK: - Colors
    var backgroundColor: Color {
        isDarkMode ? Color("Paleta3") : Color("Paleta6")
    }
    
    var cardBackgroundColor: Color {
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
    
    // MARK: - Initialization
    init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: darkModeKey) as? Bool ?? true
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    func setupDependencies(userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
        
        setupDarkModeListeners()
        loadDarkModeFromFirestore()
    }
}

// MARK: - Logic & Updates
extension ThemeManager {
    
    func toggleDarkMode() {
        let newDarkMode = !isDarkMode
        updateDarkModeLocally(newDarkMode)
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
    
    private func updateSystemAppearance() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
}

// MARK: - Firestore Sync
extension ThemeManager {
    
    private func setupDarkModeListeners() {
        NotificationCenter.default.publisher(for: .darkModeChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let isDarkMode = notification.userInfo?["isDarkMode"] as? Bool {
                    self?.updateDarkModeLocally(isDarkMode)
                }
            }
            .store(in: &cancellables)
        
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
        
        userService.startListeningForUserUpdates(uid: userId)
        
        Task {
            do {
                let user = try await userService.fetchUser(uid: userId)
                self.updateDarkModeLocally(user.settings.isDarkMode)
            } catch {
                
            }
        }
    }
    
    private func stopFirestoreListening() {
        userService?.stopListeningForUserUpdates()
    }
    
    private func syncDarkModeWithFirestore(isDarkMode: Bool) {
        guard let userId = authViewModel?.currentUserUID,
              let userService = userService else { return }
        
        Task {
            do {
                try await userService.updateDarkMode(uid: userId, isDarkMode: isDarkMode)
            } catch {
                
            }
        }
    }
}
