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
    private let darkModeKey = "isDarkMode"
    
    // ZMĚNA: Závisí na AuthService a UserService
    private lazy var userService: UserService = { DIContainer.shared.resolve() }()
    private lazy var authService: AuthService = { DIContainer.shared.resolve() }()
    
    var backgroundColor: Color { isDarkMode ? Color("Paleta3") : Color("Paleta6") }
    var cardBackgroundColor: Color { isDarkMode ? Color("Paleta5") : Color("Paleta4").opacity(0.1) }
    var primaryTextColor: Color { isDarkMode ? .white : .black }
    var secondaryTextColor: Color { isDarkMode ? Color("Paleta4") : Color("Paleta4").opacity(0.7) }
    var accentColor: Color { Color("Paleta2") }
    
    init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: darkModeKey) as? Bool ?? true
        
        // Bezpečné spuštění listenerů
        Task {
            setupListeners()
        }
    }
    
    func toggleDarkMode() {
        setDarkMode(!isDarkMode)
    }
    
    func setDarkMode(_ enabled: Bool) {
        updateLocalState(enabled)
        
        if let userId = authService.user?.uid {
            Task {
                try? await userService.updateDarkMode(uid: userId, isDarkMode: enabled)
            }
        }
    }
    
    private func updateLocalState(_ enabled: Bool) {
        guard isDarkMode != enabled else { return }
        
        isDarkMode = enabled
        UserDefaults.standard.set(enabled, forKey: darkModeKey)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = enabled ? .dark : .light
            }
        }
    }
    
    private func setupListeners() {
        NotificationCenter.default.publisher(for: .darkModeChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let serverDarkMode = notification.userInfo?["isDarkMode"] as? Bool {
                    self?.updateLocalState(serverDarkMode)
                }
            }
            .store(in: &cancellables)
        
        // ZMĚNA: Sledujeme AuthService místo AuthViewModel
        authService.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                
                if isLoggedIn, let uid = self.authService.user?.uid {
                    self.userService.startListeningForUserUpdates(uid: uid)
                } else {
                    self.userService.stopListeningForUserUpdates()
                }
            }
            .store(in: &cancellables)
    }
}
