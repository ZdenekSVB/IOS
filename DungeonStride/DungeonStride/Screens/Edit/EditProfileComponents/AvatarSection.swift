//
//  AvatarSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct AvatarSection: View {
    let selectedAvatar: String
    let accentColor: Color
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onTap) {
                ZStack {
                    Image(selectedAvatar == "default" ? "default" : selectedAvatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(accentColor, lineWidth: 3)
                        )
                        .shadow(radius: 5)
                    
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(Circle().fill(accentColor))
                        .offset(x: 40, y: 40)
                }
            }
            
            Text("Change Avatar") // Lokalizace
                .font(.caption)
                .foregroundColor(accentColor)
        }
    }
}
