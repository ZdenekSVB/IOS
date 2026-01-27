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
            // Pozadí
            Image("dungeon_bg")  // Ujisti se, že máš tento obrázek v Assets
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.8))  // Tmavší pro atmosféru

            VStack(spacing: 30) {

                // HLAVIČKA
                VStack(spacing: 5) {
                    Text(viewModel.activeDungeonId ?? "Ruiny")
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text(
                        "Místnost \(viewModel.ruinsCurrentRoom) / \(viewModel.ruinsMaxRooms)"
                    )
                    .font(.headline)
                    .foregroundColor(.gray)
                }
                .padding(.top, 60)

                Spacer()

                // DVEŘE (Grid 3 vedle sebe, nebo 1 pokud Boss)
                HStack(spacing: 15) {
                    ForEach(viewModel.currentDoors) { door in
                        RuinsDoorCard(door: door) {
                            viewModel.selectDoor(door: door)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // LOG
                Text(viewModel.ruinsLog)
                    .font(.body).bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 50)
            }
        }
    }
}
