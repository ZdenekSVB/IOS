//
//  SpellMenuGrid.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct SpellsMenuGrid: View {
    @ObservedObject var viewModel: CombatViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation { viewModel.actionMenuState = .attacks }
                }) {
                    Label("Zpět", systemImage: "arrow.uturn.left")
                        .font(.caption).bold()
                }
                .foregroundColor(.white)
                Spacer()
                Text("Kniha kouzel").font(.caption).foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 60)  // <--- Odsazení hlavičky
            .padding(.top, 10)

            if viewModel.availableSpells.isEmpty {
                Spacer()
                Text("Neznáš žádná kouzla.").font(.caption).foregroundColor(
                    .gray
                )
                Spacer()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.availableSpells) { spell in
                            Button(action: { viewModel.castSpell(spell: spell) }
                            ) {
                                VStack(spacing: 2) {
                                    Image(systemName: "sparkles")  // Nebo spell.item.iconName
                                        .font(.title3)
                                        .foregroundColor(.cyan)

                                    Text(spell.item.name)
                                        .font(.caption2).bold()
                                        .lineLimit(1)
                                        .foregroundColor(.white)

                                    if let mana = spell.item.costs.manaCost {
                                        Text("\(mana) MP")
                                            .font(.system(size: 8))
                                            .foregroundColor(.cyan.opacity(0.8))
                                    }
                                }
                                .frame(width: 80, height: 80)  // Trochu menší čtverec
                                .background(Color.purple.opacity(0.25))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.purple.opacity(0.6),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 60)  // <--- Odsazení obsahu ScrollView
                    .padding(.vertical, 10)
                }
            }
            Spacer()
        }
    }
}
