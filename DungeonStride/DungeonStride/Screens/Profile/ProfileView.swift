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
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userService: UserService(), authViewModel: AuthViewModel()))
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
                            user: user
                        )
                        
                        StatsGridView(user: user)
                        ActionButtonsView(logoutAction: viewModel.logout)
                    } else {
                        ProgressView("Loading profile...")
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
            // Re-inject dependencies if needed, or simply update local state from user
            if let avatar = userService.currentUser?.selectedAvatar {
                viewModel.selectedAvatar = avatar
            }
        }
    }
}

// MARK: - Subviews

struct ProfileHeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedAvatar: String
    @Binding var showAvatarPicker: Bool
    @Binding var showSettings: Bool
    let user: User
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor)
                        .padding(8)
                        .background(themeManager.cardBackgroundColor)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal)
            
            Button(action: { showAvatarPicker = true }) {
                Image(selectedAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 3))
                    .shadow(radius: 6)
            }
            
            Text(user.username)
                .font(.title2.bold())
                .foregroundColor(themeManager.primaryTextColor)
            
            xpProgress(for: user)
        }
        .padding(.horizontal)
    }
    
    private func xpProgress(for user: User) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(user.level)")
                    .font(.headline)
                    .foregroundColor(themeManager.accentColor)
                Spacer()
                Text("\(user.totalXP) XP")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            ProgressView(value: user.levelProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
                .frame(height: 8)
                .cornerRadius(4)
        }
        .padding(.horizontal, 40)
    }
}

struct StatsGridView: View {
    let user: User
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(icon: "figure.walk", title: "Total Distance", value: "\(user.activityStats.totalDistance) km")
            StatCard(icon: "star.fill", title: "Total XP", value: "\(user.totalXP)")
            StatCard(icon: "flag.fill", title: "Runs", value: "\(user.activityStats.totalRuns)")
            StatCard(icon: "trophy.fill", title: "Achievements", value: "\(user.myAchievements.count)")
        }
        .padding(.horizontal)
    }
}

struct ActionButtonsView: View {
    let logoutAction: () -> Void
    
    var body: some View {
        Button("Logout", action: logoutAction)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 20)
    }
}

struct AvatarSelectionPopup: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedAvatar: String
    let predefinedAvatars: [String]
    let onSave: (String) -> Void
    let onClose: () -> Void
    
    @State private var tempSelected: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Avatar")
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                ForEach(predefinedAvatars, id: \.self) { avatar in
                    Image(avatar)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(tempSelected == avatar ? themeManager.accentColor : .clear, lineWidth: 3))
                        .onTapGesture { tempSelected = avatar }
                }
            }
            
            Button("Save Avatar") {
                if let avatar = tempSelected { onSave(avatar) }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(tempSelected == nil ? Color.gray : themeManager.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(tempSelected == nil)
            
            Button("Cancel", action: onClose)
                .foregroundColor(.gray)
        }
        .padding(24)
        .background(themeManager.cardBackgroundColor.opacity(0.95))
        .cornerRadius(20)
        .padding(.horizontal, 30)
    }
}
