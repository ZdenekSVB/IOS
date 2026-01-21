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
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userService = UserService()
    @StateObject private var questService = QuestService()
    @StateObject private var themeManager = ThemeManager()

    init() {
        // Konfigurace Firebase při startu
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Předáme služby do prostředí
                .environmentObject(authViewModel)
                .environmentObject(themeManager)
                .environmentObject(userService)
                .environmentObject(questService)
                // Aplikujeme téma
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                
                // ZDE JE OPRAVA: Propojení služeb hned při startu aplikace
                // Díky tomu má AuthViewModel přístup ke QuestService i během registrace
                .onAppear {
                    // 1. Nastavíme ThemeManager
                    themeManager.setupDependencies(
                        userService: userService,
                        authViewModel: authViewModel
                    )
                    
                    // 2. Nastavíme AuthViewModel a propojíme ho se službami
                    authViewModel.setup(
                        userService: userService,
                        questService: questService,
                        themeManager: themeManager
                    )
                }
        }
    }
}
