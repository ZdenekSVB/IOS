//
//  ProfileView.swift
//  DungeonStride
//

import SwiftUI

struct ProfileView: View {
    // Tyto objekty přicházejí z hlavní aplikace (jsou sdílené)
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    // ViewModel řeší jen lokální stav této obrazovky (např. otevření sheetu)
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    if let user = userService.currentUser {
                        // Hlavička s avatarem a tlačítkem nastavení
                        ProfileHeaderView(
                            showSettings: $viewModel.showSettings,
                            user: user,
                            themeManager: themeManager
                        )
                        
                        // Mřížka se statistikami
                        StatsGridView(user: user, themeManager: themeManager)
                        
                        // ZDE BYL LOGOUT - ODSTRANĚNO
                        // Logout je nyní přesunut do SettingsView
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
    }
}
