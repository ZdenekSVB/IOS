//
//  MerchantHeaderView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct MerchantHeaderView: View {
    let timeToNextReset: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85) // Tmavé pozadí
            
            HStack(spacing: 20) {
                // Ikona obchodníka
                Image(systemName: "person.crop.circle.badge.questionmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.yellow)
                    .padding(.leading)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Mysterious Merchant") // Lokalizace
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Items reset every 24 hours.") // Lokalizace
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Timer
                    HStack {
                        Image(systemName: "clock")
                        Text("Reset in: \(timeToNextReset)") // Lokalizace
                            .monospacedDigit()
                    }
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.orange)
                    .padding(.top, 5)
                }
                Spacer()
            }
        }
        .frame(height: 120)
    }
}
