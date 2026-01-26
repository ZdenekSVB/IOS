//
//  MainMenuGrid.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct MainMenuGrid: View {
    @ObservedObject var viewModel: CombatViewModel

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12  // Menší mezera mezi tlačítky (bylo 15)
        ) {

            CombatButton(title: "Útok", icon: "sword.fill", color: .red) {
                withAnimation { viewModel.actionMenuState = .attacks }
            }

            CombatButton(title: "Blok", icon: "shield.fill", color: .blue) {
                viewModel.performBlock()
            }

            CombatButton(title: "Batoh", icon: "backpack.fill", color: .orange)
            {
                withAnimation { viewModel.actionMenuState = .items }
            }

            CombatButton(title: "Úhyb", icon: "wind", color: .gray) {
                viewModel.performDodge()
            }
        }
        // ZDE JE TA HLAVNÍ ZMĚNA:
        .padding(.horizontal, 60)  // Bylo 40 -> Teď 60 (větší odstup od krajů)
        .padding(.top, 15)
    }
}
