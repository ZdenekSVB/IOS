//
//  CoffeeCozyApp.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.05.2025.
//

import SwiftUI
import FirebaseCore
@main
struct CoffeeCozyApp: App {
    @StateObject private var authViewModel = AuthViewModel.shared
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
        authViewModel.checkIfUserIsLoggedIn()  // <- přidej sem
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoggedIn {
                    RootTabView(isAdmin: authViewModel.isAdmin)
                } else {
                    LoginView()
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(authViewModel)
        }
    }
}
