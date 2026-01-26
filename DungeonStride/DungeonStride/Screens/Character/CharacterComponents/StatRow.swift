//
//  StatRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct StatRow: View {
    let name: String, title: String, value: Int, cost: Int, icon: String, color: Color, userCoins: Int
    let action: (String, Int) -> Void
    
    var body: some View {
        HStack {
            Label { Text(title) } icon: { Image(systemName: icon).foregroundColor(color) }
            Spacer()
            Text("\(value)").bold()
            Button(action: { action(name, cost) }) {
                HStack(spacing: 2) { Image(systemName: "plus"); Text("\(cost)") }
                    .font(.caption2).padding(.horizontal, 8).padding(.vertical, 4)
                    .background(userCoins >= cost ? Color.blue : Color.gray).foregroundColor(.white).cornerRadius(10)
            }
            .disabled(userCoins < cost)
            .buttonStyle(PlainButtonStyle())
        }
    }
}
