//
//  StatRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct StatRow: View {
    let name: String, title: LocalizedStringKey, value: Int, cost: Int, icon: String, color: Color, userCoins: Int
    let action: (String, Int) -> Void
    
    var body: some View {
        HStack {
            Label { Text(title) } icon: { Image(systemName: icon).foregroundColor(color) }
            Spacer()
            Text("\(value)").bold()
            Button(action: {
                // Haptika a zvuk (Level Up statu)
                if userCoins >= cost {
                    HapticManager.shared.mediumImpact()
                    SoundManager.shared.playSystemSuccess() // Nebo zvuk upgradu
                    action(name, cost)
                } else {
                    HapticManager.shared.error()
                }
            }) {
                HStack(spacing: 2) { Image(systemName: "plus"); Text("\(cost)") }
                    .font(.caption2).padding(.horizontal, 8).padding(.vertical, 4)
                    .background(userCoins >= cost ? Color.blue : Color.gray).foregroundColor(.white).cornerRadius(10)
            }
            .disabled(userCoins < cost)
            .buttonStyle(PlainButtonStyle())
        }
    }
}
