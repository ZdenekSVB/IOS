//
//  AttacksMenuGrid.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct AttacksMenuGrid: View {
    @ObservedObject var viewModel: CombatViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Hlavička s tlačítkem Zpět
            HStack {
                Button(action: { withAnimation { viewModel.actionMenuState = .main } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.caption).bold()
                    .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Text("Select Attack").font(.caption).foregroundColor(.gray)
                Spacer()
                // Placeholder pro zarovnání
                Spacer().frame(width: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                
                CombatButton(title: "Quick", icon: "figure.run", color: .yellow) {
                    viewModel.performQuickAttack()
                }

                CombatButton(title: "Heavy", icon: "hammer.fill", color: .red) {
                    viewModel.performHeavyAttack()
                }

                // Magie
                if !viewModel.availableSpells.isEmpty {
                    CombatButton(title: "Spells", icon: "flame.fill", color: .purple) {
                        withAnimation { viewModel.actionMenuState = .spells }
                    }
                } else {
                    // Disabled tlačítko
                    Button(action: {}) {
                        VStack(spacing: 6) {
                            Image(systemName: "lock.fill").font(.title2)
                            Text("No Spells").font(.caption).bold()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.gray)
                        .cornerRadius(16)
                    }
                    .frame(height: 75)
                    .disabled(true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
        }
    }
}
