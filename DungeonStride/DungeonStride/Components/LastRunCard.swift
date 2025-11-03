//
//  LastRunCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


import SwiftUI

struct LastRunCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Last Run")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("2 hours ago")
                    .font(.caption)
                    .foregroundColor(Color("Paleta4"))
            }
            
            // Map Image Placeholder
            ZStack {
                Rectangle()
                    .fill(Color("Paleta4").opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
                
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color("Paleta2"))
                
                Text("Forest Path")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color("Paleta3").opacity(0.8))
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
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
}

struct LastRunCard_Previews: PreviewProvider {
    static var previews: some View {
        LastRunCard()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
