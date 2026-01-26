//
//  CombatView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct CombatView: View {
    // ViewModel dostane zvenčí (např. při startu boje)
    @StateObject var viewModel: CombatViewModel
    @Environment(\.dismiss) var dismiss // Pro ukončení boje
    
    var body: some View {
        ZStack {
            // Pozadí (tmavé nebo obrázek dungeonu)
            Color.black.edgesIgnoringSafeArea(.all)
            Image("dungeon_bg") // Pokud máš pozadí, jinak zakomentuj
                .resizable()
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // --- 1. NEPŘÍTEL (Nahoře) ---
                VStack {
                    Text(viewModel.enemy.name)
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    // Health Bar Nepřítele
                    HealthBarView(current: viewModel.enemy.currentHP, max: viewModel.enemy.combatStats.hp, color: .red)
                    
                    Image(viewModel.enemy.iconName) // např. "icon_enemy_slime"
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        // Animace zásahu (třesení)
                        .offset(x: viewModel.enemyIsHit ? -10 : 0)
                        .animation(.default.repeatCount(3).speed(4), value: viewModel.enemyIsHit)
                        .overlay(
                            // Efekt poškození (červené bliknutí)
                            Color.red.opacity(viewModel.enemyIsHit ? 0.5 : 0)
                                .clipShape(Circle())
                        )
                }
                .padding(.top, 40)
                
                Spacer()
                
                // --- 2. LOG BOJE (Uprostřed) ---
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(viewModel.battleLog, id: \.self) { log in
                            Text(log)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(4)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 100)
                .padding()
                
                Spacer()
                
                // --- 3. HRÁČ (Dole) ---
                VStack {
                    // Animace zásahu hráče (celý spodek zrudne)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.player.username)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Lvl \(viewModel.player.level)")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Health Bar Hráče
                    HealthBarView(current: viewModel.player.stats.hp, max: viewModel.player.stats.maxHP, color: .green)
                        .padding(.horizontal)
                    
                    // OVLÁDACÍ TLAČÍTKA
                    if viewModel.combatState == .playerTurn {
                        HStack(spacing: 15) {
                            ActionButton(title: "Útok", icon: "sword", color: .red) {
                                viewModel.playerAttack()
                            }
                            
                            ActionButton(title: "Léčit", icon: "cross.case.fill", color: .green) {
                                viewModel.playerHeal()
                            }
                            
                            // Útěk (jen zavře okno zatím)
                            ActionButton(title: "Útěk", icon: "figure.run", color: .gray) {
                                dismiss()
                            }
                        }
                        .padding()
                        .transition(.move(edge: .bottom))
                    } else if viewModel.combatState == .enemyTurn {
                        Text("Nepřítel útočí...")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        // Konec boje (Výhra/Prohra)
                        Button(action: {
                            dismiss() // Zavřít okno
                            // Tady by se měla uložit data do firestore
                        }) {
                            Text(viewModel.combatState == .victory ? "VYBRAT ODMĚNU" : "KONEC")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.combatState == .victory ? Color.yellow : Color.gray)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
                .background(Color.black.opacity(0.7)) // Pozadí panelu hráče
                .overlay(
                    Color.red.opacity(viewModel.playerIsHit ? 0.3 : 0)
                )
            }
        }
    }
}
