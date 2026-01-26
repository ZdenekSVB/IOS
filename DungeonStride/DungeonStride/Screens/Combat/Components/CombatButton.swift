//
//  CombatButton.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct CombatButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {  // Menší mezera mezi ikonou a textem
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))  // Menší ikona (byla .title2)

                Text(title)
                    .font(.caption).bold()  // Menší písmo (bylo .callout)
            }
            .frame(maxWidth: .infinity, minHeight: 55)  // ZMENŠENO ze 70 na 55
            .background(color.opacity(0.9))  // Trochu sytější barva
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}
