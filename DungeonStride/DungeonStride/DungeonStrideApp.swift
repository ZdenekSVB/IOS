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
        FirebaseApp.configure()
        print("🚀 Firebase configured")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(themeManager)
                .environmentObject(userService)
                .environmentObject(questService)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .onAppear {
                    // Nastavit závislosti až po inicializaci
                    themeManager.setupDependencies(
                        userService: userService,
                        authViewModel: authViewModel
                    )
                    authViewModel.setupThemeManager(themeManager)
                }
        }
    }
}
