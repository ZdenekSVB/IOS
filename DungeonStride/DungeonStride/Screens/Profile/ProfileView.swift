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
                            selectedAvatar: $viewModel.selectedAvatar,
                            showAvatarPicker: $viewModel.showAvatarPicker,
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
            
            if viewModel.showAvatarPicker {
                Color.black.opacity(0.55).ignoresSafeArea().onTapGesture {
                    viewModel.showAvatarPicker = false
                }
                
                AvatarSelectionPopup(
                    selectedAvatar: $viewModel.selectedAvatar,
                    predefinedAvatars: viewModel.predefinedAvatars,
                    themeManager: themeManager,
                    onSave: { newAvatar in viewModel.updateAvatar(to: newAvatar) },
                    onClose: { viewModel.showAvatarPicker = false }
                )
                .transition(.scale)
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showSettings) { SettingsView() }
        .onAppear {
            viewModel.configure(userService: userService, authViewModel: authViewModel)
        }
    }
}
