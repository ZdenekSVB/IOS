//
//  Untitled.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct ItemsMenuGrid: View {
    @ObservedObject var viewModel: CombatViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation { viewModel.actionMenuState = .main }
                }) {
                    Label("Zpět", systemImage: "arrow.uturn.left")
                        .font(.caption).bold()
                }
                .foregroundColor(.white)
                Spacer()
                Text("Lektvary").font(.caption).foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 60)  // <--- Odsazení hlavičky
            .padding(.top, 10)

            if viewModel.consumables.isEmpty {
                Spacer()
                Text("Prázdný batoh").font(.caption).foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.consumables) { consumable in
                            Button(action: {
                                viewModel.useConsumable(consumable: consumable)
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "flask.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)

                                    Text(consumable.item.name)
                                        .font(.caption2).bold()
                                        .lineLimit(1)
                                        .foregroundColor(.white)

                                    Text("x\(consumable.quantity)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 80, height: 80)  // Trochu menší čtverec
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.white.opacity(0.2),
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
