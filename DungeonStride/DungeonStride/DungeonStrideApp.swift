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
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

// Dočasný placeholder pro hlavní aplikaci
struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Dungeon Stride!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("You are successfully logged in")
                    .foregroundColor(.secondary)
                
                Button("Logout") {
                    authViewModel.logout()
                }
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("Dungeon Stride")
        }
    }
}
