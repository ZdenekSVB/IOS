//
//  ProfileView.swift
//  DungeonStride
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    @StateObject private var viewModel: ProfileViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            userService: UserService(),
            authViewModel: AuthViewModel()
        ))
    }
    
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
                        
                        ActionButtonsView(logoutAction: viewModel.logout)
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
