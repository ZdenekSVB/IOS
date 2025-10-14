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
    
    @ObservedObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
        authViewModel.checkIfUserIsLoggedIn()
    }

    var body: some Scene {
        WindowGroup {
            Group{
                if authViewModel.isLoggedIn {
                    //
                } else {
                    LoginView()
                }
            }
        }
    }
}
