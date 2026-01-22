//
//  DungeonStrideApp.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import SwiftUI
import FirebaseCore

@main
struct DungeonStrideApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // ZMĚNA: AuthViewModel si vytváříme sami (je to jen UI stav),
    // ale služby taháme z DI (protože jsou to Singletons).
    @StateObject private var authViewModel = AuthViewModel()
    
    // Služby, které chceme mít dostupné v Environmentu pro celou appku
    @StateObject private var userService: UserService
    @StateObject private var questService: QuestService
    @StateObject private var themeManager: ThemeManager

    init() {
        FirebaseApp.configure()
        
        // Zde si vytáhneme hotové instance z DI
        _userService = StateObject(wrappedValue: DIContainer.shared.resolve())
        _questService = StateObject(wrappedValue: DIContainer.shared.resolve())
        _themeManager = StateObject(wrappedValue: DIContainer.shared.resolve())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // AuthViewModel drží stav přihlášení pro ContentView
                .environmentObject(authViewModel)
                // Služby dostupné pro celou aplikaci
                .environmentObject(themeManager)
                .environmentObject(userService)
                .environmentObject(questService)
                
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
