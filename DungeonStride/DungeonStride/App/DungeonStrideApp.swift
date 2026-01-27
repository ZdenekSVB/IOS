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
                // ZDE: Toto zajistí, že celá aplikace ví o změně režimu
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                // ZDE: Přidáme ID i sem, aby se v nejhorším případě překreslilo celé okno
                .id(themeManager.isDarkMode)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if let user = userService.currentUser, user.settings.notificationsEnabled {
                switch newPhase {
                case .background:
                    NotificationManager.shared.scheduleInactivityReminder()
                case .active:
                    NotificationManager.shared.cancelInactivityReminder()
                    NotificationManager.shared.scheduleDailyNotifications()
                default:
                    break
                }
            }
        }
    }
}
