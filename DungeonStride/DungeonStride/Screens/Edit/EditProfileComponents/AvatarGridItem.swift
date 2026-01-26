//
//  AvatarGridItem.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct AvatarGridItem: View {
    let avatarName: String
    let isSelected: Bool
    let accentColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(avatarName)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(accentColor, lineWidth: isSelected ? 4 : 0)
                )
                .shadow(radius: 3)
        }
    }
}
