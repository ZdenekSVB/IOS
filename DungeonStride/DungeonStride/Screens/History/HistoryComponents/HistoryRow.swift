//
//  HistoryRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct HistoryRow: View {
    let activity: RunActivity
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        let units = userService.currentUser?.settings.units ?? .metric
        let iconName = ActivityType(rawValue: activity.type)?.iconName ?? "figure.run"
        
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(themeManager.backgroundColor)
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                
                Image(systemName: iconName)
                    .foregroundColor(themeManager.accentColor)
                    .font(.title3)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                // Lokalizace názvu aktivity (musí být v Localizable.xcstrings klíče jako "Run", "Walk" atd.)
                Text(LocalizedStringKey(activity.type.capitalized))
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text(units.formatDistance(Int(activity.distanceKm * 1000)))
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
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
