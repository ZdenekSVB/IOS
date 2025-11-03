//
//  UserProgressCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct UserProgressCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text(authViewModel.currentUserEmail ?? "User")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Spacer()
                
                // Level badge
                VStack {
                    Text("Lvl")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("5")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            // XP Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to next level")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Spacer()
                    Text("1,250 / 2,000 XP")
                        .font(.caption)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                // Progress Bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(themeManager.cardBackgroundColor)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(width: 125, height: 8) // 1250/2000 = 62.5%
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

struct UserProgressCard_Previews: PreviewProvider {
    static var previews: some View {
        UserProgressCard()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager())
            .previewLayout(.sizeThatFits)
    }
}
