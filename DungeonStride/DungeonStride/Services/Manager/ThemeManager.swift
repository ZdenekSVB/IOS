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
    var backgroundColor: Color { isDarkMode ? Color("Paleta3") : Color("Paleta6") }
    var cardBackgroundColor: Color { isDarkMode ? Color("Paleta5") : Color("Paleta4").opacity(0.1) }
    var primaryTextColor: Color { isDarkMode ? .white : .black }
    var secondaryTextColor: Color { isDarkMode ? Color("Paleta4") : Color("Paleta4").opacity(0.7) }
    var accentColor: Color { Color("Paleta2") }
    
    // MARK: - Initialization
    init() {
        // Okamžité načtení z UserDefaults pro rychlý start UI
        self.isDarkMode = UserDefaults.standard.object(forKey: darkModeKey) as? Bool ?? true
    }
    
    func setupDependencies(userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
        
        setupListeners()
    }
    
    // MARK: - Logic
    
    func toggleDarkMode() {
        setDarkMode(!isDarkMode)
    }
    
    func setDarkMode(_ enabled: Bool) {
        // 1. Lokální update (hned)
        updateLocalState(enabled)
        
        // 2. Vzdálený update (na pozadí)
        if let userId = authViewModel?.currentUserUID {
            Task {
                try? await userService?.updateDarkMode(uid: userId, isDarkMode: enabled)
            }
        }
    }
    
    private func updateLocalState(_ enabled: Bool) {
        guard isDarkMode != enabled else { return } // Optimalizace: nepřekreslovat, pokud se nic nemění
        
        isDarkMode = enabled
        UserDefaults.standard.set(enabled, forKey: darkModeKey)
        
        // Hack pro vynucení změny vzhledu celého okna (pro systémové prvky jako Alert, Keyboard)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = enabled ? .dark : .light
            }
        }
    }
    
    // MARK: - Sync & Listeners
    
    private func setupListeners() {
        // 1. Posloucháme změny z Firestore (přes NotificationCenter, které vysílá UserService)
        NotificationCenter.default.publisher(for: .darkModeChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let serverDarkMode = notification.userInfo?["isDarkMode"] as? Bool {
                    self?.updateLocalState(serverDarkMode)
                }
            }
            .store(in: &cancellables)
        
        // 2. Reagujeme na přihlášení/odhlášení
        authViewModel?.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                if isLoggedIn, let uid = self?.authViewModel?.currentUserUID {
                    // ZDE BYLA CHYBA: Volal se startListening A ZÁROVEŇ fetch.
                    // Stačí jen začít poslouchat. První data přijdou sama.
                    self?.userService?.startListeningForUserUpdates(uid: uid)
                } else {
                    self?.userService?.stopListeningForUserUpdates()
                }
            }
            .store(in: &cancellables)
    }
}
