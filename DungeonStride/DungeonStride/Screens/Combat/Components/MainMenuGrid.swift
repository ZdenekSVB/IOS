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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            
            CombatButton(title: "Attack", icon: "sword.fill", color: .red) {
                withAnimation { viewModel.actionMenuState = .attacks }
            }

            CombatButton(title: "Block", icon: "shield.fill", color: .blue) {
                viewModel.performBlock()
            }

            CombatButton(title: "Items", icon: "backpack.fill", color: .orange) {
                withAnimation { viewModel.actionMenuState = .items }
            }

            CombatButton(title: "Dodge", icon: "wind", color: .gray) {
                viewModel.performDodge()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
}
