//
//  RuinsView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 27.01.2026.
//

import SwiftUI

struct RuinsView: View {
    @ObservedObject var viewModel: DungeonMapViewModel

    var body: some View {
        ZStack {
            // Tmavé pozadí ruin
            Image("dungeon_bg")  // Ujisti se, že máš background
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.8))  // Ztmavení

            VStack(spacing: 20) {

                // --- HLAVIČKA ---
                VStack(spacing: 5) {
                    Text(viewModel.activeDungeonId ?? "Staré Ruiny")
                        .font(.system(size: 28, weight: .black, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 10)

                    Text(
                        "Místnost \(viewModel.ruinsCurrentRoom) / \(viewModel.ruinsMaxRooms)"
                    )
                    .font(.headline)
                    .foregroundColor(.gray)
                }
                .padding(.top, 60)

                Spacer()

                // --- DVEŘE ---
                HStack(spacing: 15) {
                    ForEach(viewModel.currentDoors) { door in
                        RuinsDoorCard(door: door) {
                            // Akce při kliknutí
                            withAnimation(.easeInOut(duration: 0.5)) {
                                viewModel.selectDoor(door: door)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 250)  // Fixní výška pro dveře

                Spacer()

                // --- LOG / INFO ---
                // Zobrazíme log v hezčím rámečku
                VStack(spacing: 8) {
                    Text(viewModel.ruinsLog)
                        .font(.body).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(
                                            Color.purple.opacity(0.5),
                                            lineWidth: 1
                                        )
                                )
                        )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}
