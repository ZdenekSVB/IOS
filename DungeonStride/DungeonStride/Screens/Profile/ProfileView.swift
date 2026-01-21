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
                        ProfileHeaderView(
                            showSettings: $viewModel.showSettings,
                            user: user,
                            themeManager: themeManager
                        )
                        
                        StatsGridView(user: user, themeManager: themeManager)
                        
                        // Zde voláme logout přímo na sdíleném AuthViewModelu
                        ActionButtonsView(logoutAction: {
                            authViewModel.logout()
                        })
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
