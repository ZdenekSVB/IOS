//
//  LastRunCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct LastRunCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Last Run")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Spacer()
                
                Text("2 hours ago")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            // Map Image Placeholder
            ZStack {
                Rectangle()
                    .fill(themeManager.secondaryTextColor.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
                
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundColor(themeManager.accentColor)
                
                Text("Forest Path")
                    .font(.caption)
                    .foregroundColor(themeManager.primaryTextColor)
                    .padding(8)
                    .background(themeManager.backgroundColor.opacity(0.8))
                    .cornerRadius(6)
                    .offset(y: 30)
            }
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatItem(icon: "figure.walk", title: "Distance", value: "5.2 km")
                StatItem(icon: "bolt.fill", title: "Energy", value: "85%")
                StatItem(icon: "star.fill", title: "XP", value: "250")
                StatItem(icon: "heart.fill", title: "Stamina", value: "72%")
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

struct LastRunCard_Previews: PreviewProvider {
    static var previews: some View {
        LastRunCard()
            .environmentObject(ThemeManager())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
