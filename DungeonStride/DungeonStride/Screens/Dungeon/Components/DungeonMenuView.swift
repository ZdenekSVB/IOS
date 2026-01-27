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

    var progressIndex: Int {
        return viewModel.user?.dungeonProgress[location.name] ?? 0
    }

    var body: some View {
        VStack(spacing: 15) {
            Text("Průzkum: \(location.name)")
                .font(.headline)
                .padding(.bottom, 5)

            if isLoading {
                ProgressView("Načítám monstra...")
            } else if dungeonEnemies.isEmpty {
                Text("Vypadá to, že je tu klid...")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                // Seznam nepřátel (Stages)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(
                            Array(dungeonEnemies.enumerated()),
                            id: \.offset
                        ) { index, enemy in
                            HStack {
                                Image(enemy.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .grayscale(
                                        index > progressIndex ? 1.0 : 0.0
                                    )
                                    .opacity(index > progressIndex ? 0.5 : 1.0)

                                VStack(alignment: .leading) {
                                    Text(enemy.name)
                                        .font(.system(size: 16, weight: .bold))

                                    HStack {
                                        Text("Lvl \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Text(enemy.rarity)
                                            .font(.caption2).bold()
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                rarityColor(enemy.rarity)
                                                    .opacity(0.2)
                                            )
                                            .foregroundColor(
                                                rarityColor(enemy.rarity)
                                            )
                                            .cornerRadius(4)
                                    }
                                }

                                Spacer()

                                if index < progressIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                } else if index == progressIndex {
                                    Button(action: { startFight(with: enemy) })
                                    {
                                        Text("BOJOVAT")
                                            .font(.caption).bold()
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                } else {
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
                    .padding(.horizontal)
                }
            }
        }
        .task {
            await loadEnemies()
        }
    }

    func loadEnemies() async {
        print("🔍 NAČÍTÁM ENEMIES PRO: \(location.name)")

        // 1. Zkontrolujeme, co je v IDčkách
        guard let enemyIds = location.enemyIds, !enemyIds.isEmpty else {
            print("⚠️ Tato lokace nemá žádné enemyIds (nebo je nil)!")
            self.isLoading = false
            return
        }

        print("📋 Seznam IDček k načtení: \(enemyIds)")

        // 2. Stáhneme data
        if let loaded = await viewModel.fetchEnemies(ids: enemyIds) {
            self.dungeonEnemies = loaded
            print("✅ Staženo monster: \(loaded.count)")
            for enemy in loaded {
                print("   -> \(enemy.name) (ID: \(enemy.id ?? "nil"))")
            }
        } else {
            print("❌ Nepodařilo se stáhnout žádná monstra.")
        }

        self.isLoading = false
    }

    func startFight(with enemy: Enemy) {
        dismiss()
        viewModel.currentEnemy = enemy
        viewModel.activeDungeonId = location.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            viewModel.showCombat = true
        }
    }

    func rarityColor(_ rarity: String) -> Color {
        switch rarity {
        case "Common": return .gray
        case "Uncommon": return .green
        case "Rare": return .blue
        case "Epic": return .purple
        case "Legendary": return .orange
        default: return .primary
        }
    }
}
