//
//  CombatButton.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct CombatButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact() // Haptika
            SoundManager.shared.playSystemClick() // Zvuk
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    color.opacity(0.8) // Základní barva
                    
                    // Gradient pro "skleněný" efekt
                    LinearGradient(
                        colors: [.white.opacity(0.15), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            // Jemný okraj
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .frame(height: 75) // Fixní výška
    }
}
