//
//  StatItem.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit


struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(themeManager.accentColor)
                Text(title)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.primaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(themeManager.backgroundColor.opacity(0.5))
        .cornerRadius(8)
    }
}
