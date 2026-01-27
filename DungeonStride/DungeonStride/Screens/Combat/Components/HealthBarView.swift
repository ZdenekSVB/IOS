//
//  HealthBarView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct HealthBarView: View {
    let current: Int
    let max: Int
    let color: Color

    var percent: Double {
        guard max > 0 else { return 0 }
        return Double(current) / Double(max)
    }

    var body: some View {
        VStack(spacing: 4) {
            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Pozadí (šedá)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 12)
                    
                    // Popředí (barva)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(percent), height: 12)
                        .animation(.spring(), value: percent) // Animace změny
                }
            }
            .frame(width: 100, height: 12)
            .shadow(color: color.opacity(0.3), radius: 3)
            
            // Text
            Text("\(current) / \(max)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}
