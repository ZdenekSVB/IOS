//
//  UserAvatarView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct UserAvatarView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 6) {
            Image(user.selectedAvatar)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
            
            HStack(spacing: 4) {
                Text("Lvl \(user.level)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text(user.username)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.75))
            .cornerRadius(10)
        }
        .offset(y: -55)
    }
}
