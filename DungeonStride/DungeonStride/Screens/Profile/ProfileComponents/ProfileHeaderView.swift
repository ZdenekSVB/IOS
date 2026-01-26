//
//  ProfileHeaderView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Binding var showSettings: Bool
    let user: User
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Tlačítko Nastavení
            HStack {
                Spacer()
                Button(action: {
                    // Haptika a zvuk
                    HapticManager.shared.mediumImpact()
                    SoundManager.shared.playSystemClick()
                    showSettings = true
                }) {
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
            
            // Avatar
            Image(user.selectedAvatar == "default" ? "default" : user.selectedAvatar)
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
                    // Lokalizovaný string s parametrem (Level %lld)
                    Text("Level \(user.level)")
                        .font(.headline)
                        .foregroundColor(themeManager.accentColor)
                    Spacer()
                    Text("\(user.totalXP) XP")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(themeManager.cardBackgroundColor)
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
            .padding(.horizontal, 40)
        }
        .padding(.horizontal)
    }
}
