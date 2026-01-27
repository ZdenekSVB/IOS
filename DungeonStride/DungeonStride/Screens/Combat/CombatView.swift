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
    
    // Pro shake efekt
    @State private var playerShake: CGFloat = 0
    @State private var enemyShake: CGFloat = 0

    var body: some View {
        ZStack {
            // --- 1. POZADÍ (Dungeon atmosféra) ---
            ZStack {
                Color.black.ignoresSafeArea()
                Image("dungeon_bg") // Ujisti se, že máš tento asset, jinak dej jen barvu
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.4)
            }

            VStack(spacing: 0) {
                
                // --- 2. SOUBOJOVÁ ARÉNA ---
                HStack(alignment: .top, spacing: 0) {
                    
                    // LEVÁ STRANA: HRÁČ
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.black.opacity(0.6)).frame(width: 90, height: 90)
                            
                            if let avatar = UIImage(named: viewModel.player.selectedAvatar) {
                                Image(uiImage: avatar).resizable().scaledToFill().frame(width: 85, height: 85).clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill").resizable().padding(20).frame(width: 85, height: 85).foregroundColor(.gray)
                            }
                        }
                        .overlay(Circle().stroke(Color.green, lineWidth: 3))
                        .overlay(Color.red.opacity(viewModel.playerIsHit ? 0.6 : 0).clipShape(Circle()))
                        .offset(x: playerShake) // Shake efekt
                        
                        Text(viewModel.player.username)
                            .font(.caption).bold().foregroundColor(.white).shadow(radius: 2)
                        
                        HealthBarView(current: viewModel.player.stats.hp, max: viewModel.player.stats.maxHP, color: .green)
                        
                        // Staty (zjednodušené pro boj)
                        HStack(spacing: 12) {
                            statIcon(icon: "sword.fill", val: viewModel.totalPhysicalAttack, color: .white)
                            statIcon(icon: "shield.fill", val: viewModel.totalPhysicalDefense, color: .blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // STŘED: VS
                    Text("VS")
                        .font(.system(size: 40, weight: .black, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.1))
                        .padding(.top, 40)
                        .frame(width: 60)
                    
                    // PRAVÁ STRANA: NEPŘÍTEL
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.black.opacity(0.6)).frame(width: 90, height: 90)
                            
                            Image(viewModel.enemy.iconName) // Asset enemy
                                .resizable().scaledToFit().padding(10).frame(width: 85, height: 85)
                        }
                        .overlay(Circle().stroke(Color.red, lineWidth: 3))
                        .overlay(Color.red.opacity(viewModel.enemyIsHit ? 0.6 : 0).clipShape(Circle()))
                        .offset(x: enemyShake) // Shake efekt
                        
                        Text(viewModel.enemy.name)
                            .font(.caption).bold().foregroundColor(.red).shadow(radius: 2)
                        
                        HealthBarView(current: viewModel.enemy.currentHP, max: viewModel.enemy.combatStats.hp, color: .red)
                        
                        HStack(spacing: 12) {
                            statIcon(icon: "sword.fill", val: viewModel.enemy.combatStats.physicalDamage, color: .white)
                            statIcon(icon: "shield.fill", val: viewModel.enemy.combatStats.physicalDefense, color: .orange)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 60)
                .padding(.horizontal)
                
                Spacer()
                
                // --- 3. BATTLE LOG ---
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(viewModel.battleLog, id: \.self) { log in
                                Text(log)
                                    .font(.caption).bold()
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(15)
                                    .transition(.opacity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    }
                    .frame(height: 120) // Fixní výška logu
                }
                
                Spacer()
                
                // --- 4. OVLÁDACÍ PANEL ---
                ZStack {
                    // Pozadí panelu
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                        .ignoresSafeArea()
                    
                    if viewModel.combatState == .playerTurn {
                        switch viewModel.actionMenuState {
                        case .main: MainMenuGrid(viewModel: viewModel)
                        case .attacks: AttacksMenuGrid(viewModel: viewModel)
                        case .spells: SpellsMenuGrid(viewModel: viewModel)
                        case .items: ItemsMenuGrid(viewModel: viewModel)
                        }
                    } else if viewModel.combatState == .enemyTurn {
                        VStack(spacing: 10) {
                            ProgressView().tint(.white)
                            Text("Enemy Turn...")
                                .font(.headline).foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        // Konec boje
                        Button(action: {
                            HapticManager.shared.success()
                            dismiss()
                        }) {
                            Text(viewModel.combatState == .victory ? "CLAIM REWARD" : "FINISH")
                                .font(.headline).bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.combatState == .victory ? Color.yellow : Color.gray)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .padding(40)
                    }
                }
                .frame(height: 220) // Výška spodního panelu
            }
        }
        // Reakce na zásahy (Shake animace)
        .onChange(of: viewModel.playerIsHit) { _, hit in
            if hit { withAnimation(.default) { playerShake = 10 }; withAnimation(.default.delay(0.1)) { playerShake = -10 }; withAnimation(.default.delay(0.2)) { playerShake = 0 }
                HapticManager.shared.heavyImpact()
            }
        }
        .onChange(of: viewModel.enemyIsHit) { _, hit in
            if hit { withAnimation(.default) { enemyShake = 10 }; withAnimation(.default.delay(0.1)) { enemyShake = -10 }; withAnimation(.default.delay(0.2)) { enemyShake = 0 }
                HapticManager.shared.mediumImpact()
            }
        }
    }
    
    func statIcon(icon: String, val: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text("\(val)").font(.caption2).bold()
        }
        .foregroundColor(color.opacity(0.9))
    }
}

// Pomocná struktura pro Blur efekt (jako sklo)
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: blurStyle)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = UIBlurEffect(style: blurStyle) }
}
