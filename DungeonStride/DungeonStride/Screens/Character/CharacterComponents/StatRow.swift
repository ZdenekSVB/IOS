//
//  StatRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct StatRow: View {
    let name: String
    let title: LocalizedStringKey
    let value: Int
    let cost: Int
    let icon: String
    let color: Color
    let currency: Int
    let action: (String, Int) -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Label {
                Text(title).foregroundColor(themeManager.primaryTextColor)
            } icon: {
                Image(systemName: icon).foregroundColor(color)
            }
            
            Spacer()
            
            Text("\(value)")
                .bold()
                .foregroundColor(themeManager.primaryTextColor)
                .padding(.trailing, 8)
            
            Button(action: {
                if currency >= cost {
                    HapticManager.shared.mediumImpact()
                    SoundManager.shared.playSystemSuccess()
                    action(name, cost)
                } else {
                    HapticManager.shared.error()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(currency >= cost ? .green : themeManager.secondaryTextColor.opacity(0.3))
            }
            .disabled(currency < cost)
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}
