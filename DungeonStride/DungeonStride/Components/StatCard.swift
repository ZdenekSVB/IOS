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
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
}
