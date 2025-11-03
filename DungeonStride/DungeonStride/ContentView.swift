//
//  ContentView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                HomeView()  // ← ZMĚNA: MainAppView na HomeView
            } else {
                WelcomeView()
            }
        }
        .environmentObject(authViewModel)
    }
}
#Preview {
    //ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
