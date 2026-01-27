//
//  RuinsDoorCard.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 27.01.2026.
//

import SwiftUI

struct RuinsDoorCard: View {
    let door: RuinsDoor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        door.isRevealed ? Color.black.opacity(0.6) : Color.brown
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(radius: 10)

                if door.isRevealed {
                    VStack {
                        if door.type == .combat || door.type == .boss {
                            Image(door.type.icon)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(door.type.color)
                        } else {
                            Image(systemName: door.type.icon)
                                .font(.system(size: 40))
                                .foregroundColor(door.type.color)
                        }

                        Text(door.type.rawValue)
                            .font(.caption).bold()
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                } else {
                    VStack {
                        Image(systemName: "door.left.hand.closed")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.8))

                        Text("???")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .frame(height: 180)
        }
        .disabled(door.isRevealed)
    }
}
