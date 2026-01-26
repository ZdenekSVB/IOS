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
        VStack {
            // Hlavička
            HStack {
                Button("Zpět") {
                    withAnimation { viewModel.actionMenuState = .main }
                }
                .font(.caption).bold()
                Spacer()
                Text("Zvol typ útoku").font(.caption).foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 60)  // <--- Odsazení hlavičky
            .padding(.top, 10)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12  // Menší mezera
            ) {

                CombatButton(
                    title: "Rychlý",
                    icon: "figure.run",
                    color: .yellow
                ) {
                    viewModel.performQuickAttack()
                }

                CombatButton(title: "Silný", icon: "hammer.fill", color: .red) {
                    viewModel.performHeavyAttack()
                }

                // Magie
                if !viewModel.availableSpells.isEmpty {
                    CombatButton(
                        title: "Magie",
                        icon: "flame.fill",
                        color: .purple
                    ) {
                        withAnimation { viewModel.actionMenuState = .spells }
                    }
                } else {
                    CombatButton(
                        title: "Magie",
                        icon: "flame",
                        color: .gray.opacity(0.5)
                    ) {}
                    .disabled(true)
                }
            }
            .padding(.horizontal, 60)  // <--- Odsazení tlačítek (stejné jako MainMenu)
            .padding(.bottom, 15)
        }
    }
}
