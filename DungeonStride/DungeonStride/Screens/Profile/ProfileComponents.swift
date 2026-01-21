//
//  ProfileComponents.swift
//  DungeonStride
//

import SwiftUI

struct ProfileHeaderView: View {
    // Pouze zobrazujeme, neupravujeme
    @Binding var showSettings: Bool
    let user: User
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Tlačítko Nastavení
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
            
            // Avatar (Pouze obrázek, ne tlačítko)
            Image(user.selectedAvatar)
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 3))
                .shadow(radius: 6)
            
            // Jméno
            Text(user.username)
                .font(.title2.bold())
                .foregroundColor(themeManager.primaryTextColor)
            
            // Level a XP
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
