//
//  ActionButtonView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.caption).bold()
            }
            .frame(width: 80, height: 80)
            .background(color.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 5)
        }
    }
}
