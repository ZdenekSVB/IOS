//
//  DetailStatCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct DetailStatCard: View {
    let title: LocalizedStringKey // Změna na LocalizedStringKey
    let value: String
    let icon: String
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.accentColor)
                Text(title) // SwiftUI si poradí s LocalizedStringKey
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .textCase(.uppercase) // Uppercase řešíme zde modifikátorem
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
