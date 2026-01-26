//
//  ContentView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                HomeView()
                    .transition(.opacity)  // Hladký přechod
            } else {
                WelcomeView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: authViewModel.isLoggedIn)  // Animace změny stavu
    }
}
