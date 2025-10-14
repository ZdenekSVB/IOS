//
//  DungeonStrideApp.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import SwiftUI

@main
struct DungeonStrideApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
