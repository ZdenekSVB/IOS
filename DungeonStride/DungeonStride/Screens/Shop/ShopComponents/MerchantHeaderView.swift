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
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            HStack(spacing: 20) {
                // IKONA OBCHODNÍKA
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 70, height: 70)
                    
                    if UIImage(named: "Merchant") != nil {
                        Image("Merchant")
                            .resizable().scaledToFill().frame(width: 64, height: 64).clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.badge.questionmark.fill")
                            .resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.yellow)
                    }
                }
                .padding(.leading)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mysterious Merchant")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                        .shadow(color: .orange.opacity(0.5), radius: 5)
                    
                    Text("New wares every 24h.")
                        .font(.caption).foregroundColor(.gray)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "hourglass").foregroundColor(.orange)
                        Text("Reset in: \(timeToNextReset)")
                            .font(.system(.caption, design: .monospaced)).bold().foregroundColor(.orange)
                    }
                    .padding(.top, 2)
                }
                Spacer()
            }
        }
        .frame(height: 130)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.1)), alignment: .bottom)
    }
}
