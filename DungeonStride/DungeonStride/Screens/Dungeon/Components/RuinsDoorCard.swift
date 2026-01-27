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
                // 1. VRSTVA: VNITŘEK (Co je za dveřmi)
                // Zobrazí se, jen když jsou dveře otevřené (isRevealed)
                if door.isRevealed {
                    VStack(spacing: 10) {
                        // Ikona Lootu / Monstra
                        if door.type == .combat || door.type == .boss {
                            Image(door.type.icon)  // Tvoje custom asset ikona
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(door.type.color)
                        } else {
                            Image(systemName: door.type.icon)
                                .font(.system(size: 50))
                                .foregroundColor(door.type.color)
                        }

                        Text(door.type.rawValue.uppercased())
                            .font(.caption2).bold()
                            .foregroundColor(door.type.color)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))  // Tmavé pozadí vnitřku
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(door.type.color, lineWidth: 2)
                    )
                    // Animace objevení obsahu
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                // 2. VRSTVA: DVEŘE (Zavřené / Otevřené)
                // Pokud jsou isRevealed, zobrazíme obrázek otevřených dveří (nebo je skryjeme, pokud chceš vidět jen loot)
                // Zde uděláme variantu s obrázky:

                if !door.isRevealed {
                    Image("door_closed")  // Vlož tento obrázek do Assets!
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .shadow(color: .black, radius: 5, x: 0, y: 5)
                        .transition(.opacity)  // Při zmizení se prolne
                } else {
                    // Volitelné: Obrázek rámu otevřených dveří přes loot
                    Image("door_open")  // Vlož tento obrázek do Assets! (Musí mít průhledný střed!)
                        .resizable()
                        .scaledToFit()
                        .allowsHitTesting(false)  // Aby neblokoval
                        .opacity(0.6)  // Trochu průhledné, aby byl vidět loot
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(0.6, contentMode: .fit)  // Poměr stran dveří
        }
        .disabled(door.isRevealed)  // Nelze kliknout znovu
    }
}
