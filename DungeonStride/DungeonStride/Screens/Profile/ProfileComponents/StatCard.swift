//
//  StatCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let themeManager: ThemeManager // Přidáno, aby komponenta byla soběstačná
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
                .padding(10)
                .background(themeManager.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
