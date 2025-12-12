//
//  ProfileComponents.swift
//  DungeonStride
//

import SwiftUI

struct ProfileHeaderView: View {
    @Binding var selectedAvatar: String
    @Binding var showAvatarPicker: Bool
    @Binding var showSettings: Bool
    let user: User
    let themeManager: ThemeManager
    
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
        .padding(.horizontal)
    }
}

struct StatsGridView: View {
    let user: User
    let themeManager: ThemeManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            
            // OPRAVENO: Použití user.settings.units.formatDistance() místo natvrdo napsaného "km"
            StatCard(
                icon: "figure.walk",
                title: "Total Distance",
                value: user.settings.units.formatDistance(user.activityStats.totalDistance)
            )
            
            StatCard(
                icon: "star.fill",
                title: "Total XP",
                value: "\(user.totalXP)"
            )
            
            StatCard(
                icon: "flag.fill",
                title: "Runs",
                value: "\(user.activityStats.totalRuns)"
            )
            
            StatCard(
                icon: "trophy.fill",
                title: "Achievements",
                value: "\(user.myAchievements.count)"
            )
        }
        .padding(.horizontal)
        .environmentObject(themeManager)
    }
}

struct ActionButtonsView: View {
    let logoutAction: () -> Void
    
    var body: some View {
        Button("Logout", action: logoutAction)
            .buttonStyle(PrimaryButtonStyle(backgroundColor: .red))
            .padding(.horizontal)
            .padding(.bottom, 20)
    }
}

struct AvatarSelectionPopup: View {
    @Binding var selectedAvatar: String
    let predefinedAvatars: [String]
    let themeManager: ThemeManager
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
            .buttonStyle(PrimaryButtonStyle(backgroundColor: tempSelected == nil ? Color.gray : themeManager.accentColor))
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
