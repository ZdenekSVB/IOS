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
    let persistenceController = PersistenceController.shared
    init() {FirebaseApp.configure()}
    
    
    var body: some Scene {

        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
