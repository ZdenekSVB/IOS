//
//  UserProgressCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct UserProgressCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Avatar
                if let avatar = userService.currentUser?.selectedAvatar {
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(themeManager.accentColor)
                }
                
                VStack(alignment: .leading) {
                    Text("Welcome back!", comment: "Greeting on home screen")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text(userService.currentUser?.username ?? "Adventurer")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Spacer()
                
                // Level Badge
                VStack {
                    Text("Lvl")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("\(userService.currentUser?.level ?? 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            // XP Progress
            if let user = userService.currentUser {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next Level", comment: "Label above XP bar")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                        Text("\(user.totalXP) / \(user.level * 100) XP")
                            .font(.caption)
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(themeManager.cardBackgroundColor.opacity(0.5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(themeManager.accentColor)
                                .frame(width: min(geometry.size.width * CGFloat(user.levelProgress), geometry.size.width), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}
