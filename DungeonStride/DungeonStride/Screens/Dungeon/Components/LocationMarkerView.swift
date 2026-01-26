//
//  LocationMarkerView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct LocationMarkerView: View {
    let location: GameMapLocation
    
    var iconName: String {
        switch location.locationType {
        case "city": return "house.fill"
        case "dungeon": return "skull.fill"
        case "ruins": return "building.columns.fill"
        case "swamp": return "drop.fill"
        default: return "mappin.circle.fill"
        }
    }
    
    var color: Color {
        switch location.locationType {
        case "city": return .blue
        case "dungeon": return .red
        case "ruins": return .orange
        case "swamp": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.system(size: 44))
                .padding(12)
                .background(color.opacity(0.8))
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .shadow(radius: 5)
            
            Text(location.name)
                .font(.system(size: 14, weight: .bold))
                .padding(6)
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(6)
        }
        .offset(y: -40)
    }
}
