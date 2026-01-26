//
//  PaceChart.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI
import MapKit
import Charts
import CoreLocation

struct PaceChart: View {
    @ObservedObject var activityManager: ActivityManager
    let themeManager: ThemeManager
    let units: DistanceUnit
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Speed (\(units.speedSymbol))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            if activityManager.rawSpeedHistory.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                        .frame(height: 120)
                    Text("Start activity to see data")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            } else {
                Chart {
                    ForEach(Array(activityManager.rawSpeedHistory.enumerated()), id: \.offset) { index, speedMs in
                        // Převedeme m/s na km/h (nebo mph/uzly) přímo v grafu
                        let convertedSpeed = units.convertSpeed(fromMetersPerSecond: speedMs)
                        
                        LineMark(
                            x: .value("Segment", index + 1),
                            y: .value("Speed", convertedSpeed)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYAxisLabel(units.speedSymbol)
                .chartYScale(domain: .automatic(includesZero: false))
            }
        }
    }
}
