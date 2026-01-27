//
//  LocationMarkerView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct LocationMarkerView: View {
    let location: GameMapLocation

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

            ZStack {
                // Pozadí
                Circle()
                    .fill(color.opacity(0.8))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(radius: 5)

                // Ikona
                if UIImage(named: location.iconName) != nil {
                    // Pokud existuje v Assets
                    Image(location.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } else {
                    // Fallback (aby to nepadlo, když chybí asset)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }

            Text(location.name)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                .lineLimit(1)
        }
        .offset(y: -30)
    }
}
