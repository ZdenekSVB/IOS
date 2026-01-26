//
//  WelcomeButton.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct WelcomeButton: View {
    let title: LocalizedStringKey // Změna na LocalizedStringKey pro lokalizaci
    let icon: String
    var isSystemImage: Bool = true
    let color: Color
    var textColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Feedback
            HapticManager.shared.lightImpact()
            SoundManager.shared.playSystemClick()
            action()
        }) {
            HStack(spacing: 12) {
                if isSystemImage {
                    Image(systemName: icon)
                } else {
                    Image(icon) // Pro custom assety
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding()
            .background(color)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
