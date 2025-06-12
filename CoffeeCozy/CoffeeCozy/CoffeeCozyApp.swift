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
    @StateObject var loginViewModel = LoginViewModel()
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if loginViewModel.isLoggedIn {
                RootTabView(isAdmin: loginViewModel.isAdmin)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
