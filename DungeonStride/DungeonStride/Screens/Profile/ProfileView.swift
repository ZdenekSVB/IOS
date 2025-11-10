//
//  ProfileView.swift
//  DungeonStride
//

import SwiftUI

// MARK: - Main Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService

    @State private var showAvatarPicker = false
    @State private var showSettings = false
    @State private var selectedAvatar: String = "avatar1"

    let predefinedAvatars = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6"]

    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    if let user = userService.currentUser {
                        ProfileHeaderView(
                            selectedAvatar: $selectedAvatar,
                            showAvatarPicker: $showAvatarPicker,
                            showSettings: $showSettings,
                            user: user
                        )

                        StatsGridView(user: user)
                        ActionButtonsView(logoutAction: authViewModel.logout)
                    } else {
                        ProgressView("Loading profile...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                }
                .padding(.top, 10)
            }

            if showAvatarPicker {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)

                AvatarSelectionPopup(
                    selectedAvatar: $selectedAvatar,
                    predefinedAvatars: predefinedAvatars,
                    onClose: { showAvatarPicker = false }
                )
                .transition(.scale)
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .onAppear {
            if let avatar = userService.currentUser?.selectedAvatar {
                selectedAvatar = avatar
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel

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
                    .overlay(
                        Circle().stroke(
                            LinearGradient(colors: [themeManager.accentColor, .purple],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 3
                        )
                    )
                    .shadow(radius: 6)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("Tap to change")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.bottom, 6)
                        }
                    )
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

// MARK: - Stats Grid
struct StatsGridView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let user: User

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(icon: "figure.walk", title: "Total Distance", value: "\(user.activityStats.totalDistance) km")
            StatCard(icon: "star.fill", title: "Total XP", value: "\(user.totalXP)")
            StatCard(icon: "flag.fill", title: "Runs Completed", value: "\(user.activityStats.totalRuns)")
            StatCard(icon: "trophy.fill", title: "Achievements", value: "\(user.myAchievements.count)")
        }
        .padding(.horizontal)
    }
}

// MARK: - Action Buttons
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

// MARK: - Avatar Selection Popup (bez custom image)
struct AvatarSelectionPopup: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager

    @Binding var selectedAvatar: String
    let predefinedAvatars: [String]
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
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(tempSelected == avatar ? themeManager.accentColor : .clear, lineWidth: 3)
                        )
                        .onTapGesture { tempSelected = avatar }
                }
            }

            Button(action: saveAvatar) {
                Text("Save Avatar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tempSelected == nil ? Color.gray : themeManager.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(tempSelected == nil)

            Button("Cancel", action: onClose)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(24)
        .background(themeManager.cardBackgroundColor.opacity(0.95))
        .cornerRadius(20)
        .padding(.horizontal, 30)
    }

    private func saveAvatar() {
        guard let selected = tempSelected,
              let uid = authViewModel.currentUserUID else { return }

        Task {
            do {
                try await userService.updateSelectedAvatar(uid: uid, avatarName: selected)
                selectedAvatar = selected
                onClose()
            } catch {
                print("❌ Failed to update avatar: \(error.localizedDescription)")
            }
        }
    }
}
