//
//  HistoryComponents.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 20.01.2026.
//
import SwiftUI

struct HistoryRow: View {
    let activity: RunActivity
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        let units = userService.currentUser?.settings.units ?? .metric
        
        // Získání ikony přímo z ActivityType bez duplicity
        // Pokud se typ v databázi neshoduje s enumem (fallback), použijeme figure.run
        let iconName = ActivityType(rawValue: activity.type)?.iconName ?? "figure.run"
        
        HStack(spacing: 16) {
            // Icon Background
            ZStack {
                Circle()
                    .fill(themeManager.backgroundColor)
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                
                Image(systemName: iconName)
                    .foregroundColor(themeManager.accentColor)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.type.capitalized)
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Distance
                Text(units.formatDistance(Int(activity.distanceKm * 1000)))
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                // Duration
                Text(activity.duration.stringFormat())
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}
