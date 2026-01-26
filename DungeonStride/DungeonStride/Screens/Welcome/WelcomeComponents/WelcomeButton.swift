//
//  WelcomeButton.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
 import SwiftUI

struct WelcomeButton: View {
    let title: String
    let icon: String
    var isSystemImage: Bool = true
    let color: Color
    var textColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSystemImage {
                    Image(systemName: icon)
                } else {
                    Image(icon) // Pro custom assety (např. Google logo)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
