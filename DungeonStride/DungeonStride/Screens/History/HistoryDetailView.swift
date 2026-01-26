//
//  HistoryDetailView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 20.01.2026.
//

import SwiftUI
import MapKit

struct HistoryDetailView: View {
    let activity: RunActivity
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 1. Mapa
                    ActivityMapCard(activity: activity)
                    
                    // 2. Statistiky (Grid)
                    ActivityStatsGrid(activity: activity)
                    
                    // 3. Datum (Footer)
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(themeManager.secondaryTextColor)
                        // Lokalizace stringu s parametrem data
                        Text("Recorded on: \(activity.timestamp.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        // Nadpis aktivity (např. Run, Walk) se lokalizuje sám, pokud jsou v Localizable.strings klíče jako "run", "walk"
        .navigationTitle(LocalizedStringKey(activity.type.capitalized))
        .navigationBarTitleDisplayMode(.inline)
    }
}
