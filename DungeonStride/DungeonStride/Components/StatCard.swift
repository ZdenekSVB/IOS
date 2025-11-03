//
//  StatCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI
// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("Paleta2"))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color("Paleta4"))
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
}
