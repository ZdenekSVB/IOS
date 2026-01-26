//
//  CombatView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct CombatView: View {
    @StateObject var viewModel: CombatViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // --- 1. POZADÍ ---
            Image("dungeon_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5))

            VStack(spacing: 0) {

                // --- 2. SOUBOJOVÁ ARÉNA (Hráč vs Enemy) ---
                HStack(alignment: .top, spacing: 0) {

                    // LEVÁ STRANA: HRÁČ
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.black.opacity(0.5)).frame(
                                width: 85,
                                height: 85
                            )

                            Image(viewModel.player.selectedAvatar)
                                .resizable().scaledToFill()
                                .frame(width: 80, height: 80).clipShape(
                                    Circle()
                                )
                                .overlay(
                                    Circle().stroke(Color.green, lineWidth: 3)
                                )
                        }
                        .overlay(
                            Color.red.opacity(viewModel.playerIsHit ? 0.7 : 0)
                                .clipShape(Circle())
                        )
                        .scaleEffect(viewModel.playerIsHit ? 0.9 : 1.0)

                        Text(viewModel.player.username)
                            .font(.caption).bold().foregroundColor(.white)
                            .shadow(radius: 2)
                            .lineLimit(1)

                        HealthBarView(
                            current: viewModel.player.stats.hp,
                            max: viewModel.player.stats.maxHP,
                            color: .green
                        )

                        HStack(spacing: 15) {
                            Label(
                                "\(viewModel.totalAttack)",
                                systemImage: "sword.fill"
                            )
                            Label(
                                "\(viewModel.totalDefense)",
                                systemImage: "shield.fill"
                            )
                        }
                        .font(.caption2).foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)

                    // STŘED: VS
                    VStack {
                        Text("VS")
                            .font(
                                .system(
                                    size: 30,
                                    weight: .black,
                                    design: .serif
                                )
                            )
                            .italic()
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.top, 25)
                    }
                    .frame(width: 50)

                    // PRAVÁ STRANA: NEPŘÍTEL
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.black.opacity(0.5)).frame(
                                width: 85,
                                height: 85
                            )

                            Image(viewModel.enemy.iconName)
                                .resizable().scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                        .offset(x: viewModel.enemyIsHit ? 10 : 0)
                        .overlay(
                            Color.red.opacity(viewModel.enemyIsHit ? 0.7 : 0)
                                .clipShape(Circle())
                        )

                        Text(viewModel.enemy.name)
                            .font(.caption).bold().foregroundColor(.red)
                            .shadow(radius: 2)
                            .lineLimit(1)

                        HealthBarView(
                            current: viewModel.enemy.currentHP,
                            max: viewModel.enemy.combatStats.hp,
                            color: .red
                        )

                        HStack(spacing: 15) {
                            Label(
                                "\(viewModel.enemy.combatStats.attack)",
                                systemImage: "sword.fill"
                            )
                            Label(
                                "\(viewModel.enemy.combatStats.defense)",
                                systemImage: "shield.fill"
                            )
                        }
                        .font(.caption2).foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 10)
                .padding(.top, 60)  // Odsazení odshora (Dynamic Island)

                // MEZERA (Tlačí Log doprostřed)
                Spacer()

                // --- 3. BATTLE LOG (UPROSTŘED) ---
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 4) {
                                ForEach(viewModel.battleLog, id: \.self) {
                                    log in
                                    Text(log)
                                        .font(.caption).bold()
                                        .foregroundColor(.white)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(15)
                                        .shadow(radius: 2)
                                    // Otočíme log, aby nové zprávy byly dole (volitelné),
                                    // ale tvůj systém vkládá na index 0, takže to necháme takto.
                                }
                            }
                            .frame(maxWidth: .infinity)  // Log přes celou šířku (centrovaný)
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: 150)  // Omezíme výšku logu, aby nezabral celou obrazovku

                // MEZERA (Tlačí Menu dolů)
                Spacer()

                // --- 4. AKČNÍ MENU (Gridy) ---
                ZStack {
                    Color(UIColor.secondarySystemBackground).opacity(0.95)
                        .ignoresSafeArea()

                    if viewModel.combatState == .playerTurn {

                        switch viewModel.actionMenuState {
                        case .main:
                            MainMenuGrid(viewModel: viewModel)
                        case .attacks:
                            AttacksMenuGrid(viewModel: viewModel)
                        case .spells:
                            SpellsMenuGrid(viewModel: viewModel)
                        case .items:
                            ItemsMenuGrid(viewModel: viewModel)
                        }

                    } else if viewModel.combatState == .enemyTurn {
                        VStack {
                            ProgressView()
                            Text("Soupeř hraje...").font(.headline).padding(
                                .top,
                                5
                            )
                        }
                        .foregroundColor(.black)

                    } else {
                        // Konec boje
                        Button(action: { dismiss() }) {
                            Text(
                                viewModel.combatState == .victory
                                    ? "VYBRAT ODMĚNU" : "KONEC"
                            )
                            .font(.headline).bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.combatState == .victory
                                    ? Color.yellow : Color.gray
                            )
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 30)  // Odsazení tlačítka konec
                        .padding(.vertical, 20)
                    }
                }
                .frame(height: 180)  // Trochu vyšší pro menu
            }
        }
    }
}
