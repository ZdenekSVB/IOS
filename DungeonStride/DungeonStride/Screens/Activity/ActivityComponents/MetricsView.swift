//
//  MetricsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI
import MapKit
import Charts
import CoreLocation

struct MetricsView: View {
    @ObservedObject var activityManager: ActivityManager
    let themeManager: ThemeManager
    let units: DistanceUnit
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
            MetricItem(
                title: "Duration",
                value: activityManager.elapsedTime.stringFormat(),
                themeManager: themeManager
            )
            
            MetricItem(
                title: "Distance",
                value: units.formatDistance(Int(activityManager.distance)),
                themeManager: themeManager
            )
            
            MetricItem(
                title: "Speed",
                // Zde se používá formátovač z DistanceUnit, který to hodí do km/h, mph nebo uzlů
                value: units.formatSpeed(metersPerSecond: activityManager.currentSpeed),
                themeManager: themeManager
            )
            
            MetricItem(
                title: "Energy",
                value: String(format: "%.0f kcal", activityManager.kcalBurned),
                themeManager: themeManager
            )
        }
    }
}
