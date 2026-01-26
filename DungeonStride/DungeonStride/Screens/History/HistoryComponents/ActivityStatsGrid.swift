//
//  ActivityStatsGrid.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct ActivityStatsGrid: View {
    let activity: RunActivity
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        let units = userService.currentUser?.settings.units ?? .metric
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            DetailStatCard(
                title: "Vzdálenost",
                value: units.formatDistance(Int(activity.distanceKm * 1000)),
                icon: "map.fill",
                themeManager: themeManager
            )
            
            DetailStatCard(
                title: "Čas",
                value: activity.duration.stringFormat(),
                icon: "stopwatch.fill",
                themeManager: themeManager
            )
            
            DetailStatCard(
                title: "Energie",
                value: "\(activity.calories) kcal",
                icon: "flame.fill",
                themeManager: themeManager
            )
            
            DetailStatCard(
                title: "Tempo",
                value: formatPace(activity.pace, unit: units),
                icon: "speedometer",
                themeManager: themeManager
            )
        }
    }
    
    private func formatPace(_ paceMinKm: Double, unit: DistanceUnit) -> String {
        if unit == .metric {
            return String(format: "%.2f min/km", paceMinKm)
        } else {
            return String(format: "%.2f min/mi", paceMinKm * 1.60934)
        }
    }
}
