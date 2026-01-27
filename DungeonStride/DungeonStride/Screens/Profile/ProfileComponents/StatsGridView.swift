//
//  StatsGridView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct StatsGridView: View {
    let user: User
    let themeManager: ThemeManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            
            // 1. Vzdálenost
            StatCard(
                icon: "figure.walk",
                title: "Total Distance", // Lokalizace
                // Používáme nastavení jednotek uživatele pro formátování
                value: user.settings.units.formatDistance(user.activityStats.totalDistance),
                themeManager: themeManager
            )
            
            // 2. XP
            StatCard(
                icon: "star.fill",
                title: "Total XP", // Lokalizace
                value: "\(user.totalXP)",
                themeManager: themeManager
            )
            
            // 3. Počet běhů
            StatCard(
                icon: "flag.fill",
                title: "Runs", // Lokalizace
                value: "\(user.activityStats.totalRuns)",
                themeManager: themeManager
            )
            
            // 4. Splněné mise (Quests)
            StatCard(
                icon: "checkmark.seal.fill",
                title: "Missions", // Lokalizace
                value: "\(user.totalQuestsCompleted)",
                themeManager: themeManager
            )
        }
        .padding(.horizontal)
    }
}
