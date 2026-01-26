//
//  DungeonMenuView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct DungeonMenuView: View {
    let location: GameMapLocation
    @ObservedObject var viewModel: DungeonMapViewModel

    // Načtení nepřátelé pro tento dungeon
    @State private var dungeonEnemies: [Enemy] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss

    // Kolik už jich porazil?
    var progressIndex: Int {
        // Pokud nemáme záznam, je to 0
        return viewModel.user?.dungeonProgress[location.name] ?? 0
    }

    var body: some View {
        VStack(spacing: 15) {
            Text("Průzkum Dungeonu")
                .font(.headline)
                .padding(.bottom, 5)

            if isLoading {
                ProgressView("Načítám monstra...")
            } else if dungeonEnemies.isEmpty {
                Text("Tento dungeon je prázdný.")
                    .foregroundColor(.secondary)
            } else {
                // Vypíšeme 3 patra (Stages)
                ForEach(Array(dungeonEnemies.enumerated()), id: \.element.id) {
                    index,
                    enemy in
                    HStack {
                        // 1. IKONA
                        Image(enemy.iconName)  // Musí být v Assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .grayscale(index > progressIndex ? 1.0 : 0.0)  // Zamčené šedivé? Volitelné.
                            .opacity(index > progressIndex ? 0.5 : 1.0)

                        // 2. INFO
                        VStack(alignment: .leading) {
                            Text(enemy.name)
                                .font(.system(size: 16, weight: .bold))
                            Text("Lvl \(index + 1)")  // Jen jako stage level
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // 3. STAV (Hotovo / Boj / Zámek)
                        if index < progressIndex {
                            // Už poražen
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        } else if index == progressIndex {
                            // Aktuální souboj
                            Button(action: {
                                startFight(with: enemy)
                            }) {
                                Text("BOJOVAT")
                                    .font(.caption).bold()
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else {
                            // Zamčeno (musí porazit předchozího)
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                index == progressIndex
                                    ? Color.red : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
            }
        }
        .task {
            await loadEnemies()
        }
    }

    func loadEnemies() async {
        // 1. Získáme IDčka pro tuto lokaci z helperu
        let enemyIds = DungeonContent.getEnemies(for: location.name)

        // 2. Stáhneme data z Firestore (nebo ViewModelu)
        // Pro jednoduchost voláme funkci z ViewModelu (musíme ji tam přidat)
        if let loaded = await viewModel.fetchEnemies(ids: enemyIds) {
            self.dungeonEnemies = loaded
        }
        self.isLoading = false
    }

    func startFight(with enemy: Enemy) {
        // Nastavíme ve ViewModelu nepřítele a spustíme boj
        dismiss()
        viewModel.currentEnemy = enemy
        viewModel.activeDungeonId = location.name  // Uložíme si, kde bojujeme, pro update progressu
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            viewModel.showCombat = true
        }
    }
}
