//
//  StatsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct StatsView: View {
    let user: User
    let onUpgrade: (String, Int) -> Void
    @EnvironmentObject var themeManager: ThemeManager // PŘIDÁNO
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Header: Available Points
                HStack {
                    Text("Available Points:") // Lokalizace
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    Spacer()
                    Text("\(user.statPoints)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(user.statPoints > 0 ? .green : .gray)
                }
                .padding()
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2)
                
                // Statistiky
                VStack(spacing: 0) {
                    let cost = 1
                    
                    StatRow(name: "physicalDamage", title: "Strength", value: user.stats.physicalDamage, cost: cost, icon: "flame.fill", color: .red, currency: user.statPoints, action: onUpgrade)
                    
                    Divider().background(themeManager.secondaryTextColor.opacity(0.2))
                    
                    StatRow(name: "defense", title: "Defense", value: user.stats.defense, cost: cost, icon: "shield.fill", color: .blue, currency: user.statPoints, action: onUpgrade)
                    
                    Divider().background(themeManager.secondaryTextColor.opacity(0.2))
                    
                    StatRow(name: "magicDamage", title: "Magic", value: user.stats.magicDamage, cost: cost, icon: "sparkles", color: .purple, currency: user.statPoints, action: onUpgrade)
                    
                    Divider().background(themeManager.secondaryTextColor.opacity(0.2))
                    
                    StatRow(name: "maxHP", title: "Vitality", value: user.stats.maxHP, cost: cost, icon: "heart.fill", color: .green, currency: user.statPoints, action: onUpgrade)
                }
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2)
                
                // Info: Current HP
                HStack {
                    Text("Health (HP)")
                        .foregroundColor(themeManager.secondaryTextColor)
                    Spacer()
                    Text("\(user.stats.hp) / \(user.stats.maxHP)")
                        .bold()
                        .foregroundColor(themeManager.primaryTextColor)
                }
                .padding()
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2)
            }
            .padding()
        }
        .background(themeManager.backgroundColor)
    }
}
