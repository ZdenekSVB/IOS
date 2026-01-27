//
//  MerchantHeaderView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct MerchantHeaderView: View {
    let timeToNextReset: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Pozadí podle Theme Manageru (žádný tvrdý černý gradient)
            themeManager.cardBackgroundColor
                .ignoresSafeArea()
            
            HStack(spacing: 20) {
                // IKONA OBCHODNÍKA
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 70, height: 70)
                    
                    if UIImage(named: "Merchant") != nil {
                        Image("Merchant")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.badge.questionmark.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.leading)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mysterious Merchant")
                        .font(.title3).bold()
                        .foregroundColor(themeManager.primaryTextColor) // Barva podle tématu
                    
                    Text("New wares every 24h.")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    // Timer
                    HStack(spacing: 6) {
                        Image(systemName: "hourglass")
                            .foregroundColor(.orange)
                        Text("Reset in: \(timeToNextReset)")
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 2)
                }
                Spacer()
            }
        }
        .frame(height: 120)
        // Odstraněn overlay (černý/bílý obdélník)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
    }
}
