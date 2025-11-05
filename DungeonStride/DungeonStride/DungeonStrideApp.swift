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
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var userService = UserService()
    @StateObject private var questService = QuestService()

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
        }
    }
}
