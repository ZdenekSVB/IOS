//
//  DungeonStrideApp.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import FirebaseCore
import SwiftUI

@main
struct DungeonStrideApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Sledujeme stav aplikace (Active / Background)
    @Environment(\.scenePhase) var scenePhase

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userService: UserService
    @StateObject private var questService: QuestService
    @StateObject private var themeManager: ThemeManager

    init() {
        FirebaseApp.configure()

        _userService = StateObject(wrappedValue: DIContainer.shared.resolve())
        _questService = StateObject(wrappedValue: DIContainer.shared.resolve())
        _themeManager = StateObject(wrappedValue: DIContainer.shared.resolve())
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
        // --- TOTO ZDE CHYBĚLO: Reakce na minimalizaci aplikace ---
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                print("🌑 Appka jde na pozadí -> Plánuji notifikaci")
                // Zde se plánuje notifikace "Vrať se do hry"
                NotificationManager.shared.scheduleInactivityReminder()
                
            case .active:
                print("☀️ Appka je aktivní -> Ruším notifikaci a obnovuji denní")
                NotificationManager.shared.cancelInactivityReminder()
                // Zároveň se ujistíme, že máme práva (vyžádá si je, pokud chybí)
                NotificationManager.shared.requestAuthorization()
                
            default:
                break
            }
        }
    }
}
