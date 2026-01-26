//
//  CombatViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

// Stavy souboje
enum CombatState {
    case playerTurn
    case enemyTurn
    case victory
    case defeat
}

@MainActor
class CombatViewModel: ObservableObject {
    @Published var player: User
    @Published var enemy: Enemy

    @Published var combatState: CombatState = .playerTurn
    @Published var battleLog: [String] = []  // Výpis co se děje ("Slime zaútočil za 5 dmg")

    // Pro animace (otřes obrazovky při zásahu)
    @Published var playerIsHit = false
    @Published var enemyIsHit = false

    var onWin: (() -> Void)?

    init(player: User, enemy: Enemy, onWin: (() -> Void)? = nil) {
        self.player = player
        self.enemy = enemy
        self.onWin = onWin

        // Resetujeme HP pro souboj (Player HP bereme z jeho stats, Enemy taky)
        // Pozor: Tady předpokládám, že player.stats.hp je aktuální stav.
        // Pokud máš maxHP a currentHP, použij currentHP.
        addToLog("Souboj začíná! \(enemy.name) se blíží.")
    }

    // --- AKCE HRÁČE ---

    func playerAttack() {
        guard combatState == .playerTurn else { return }

        // 1. Výpočet Damage
        // Formule: (Player Útok - Enemy Obrana) + náhoda
        let baseDmg = max(
            1,
            player.stats.physicalDamage - (enemy.combatStats.defense / 2)
        )
        let randomVariation = Int.random(in: -2...2)
        let finalDmg = max(1, baseDmg + randomVariation)

        // 2. Aplikace
        enemy.currentHP -= finalDmg
        enemyIsHit = true  // Trigger animace

        addToLog("Zasáhl jsi \(enemy.name) za \(finalDmg) poškození!")

        // Reset animace po chvilce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.enemyIsHit = false
        }

        // 3. Kontrola vítězství
        if enemy.currentHP <= 0 {
            enemy.currentHP = 0
            winBattle()
        } else {
            // Předáme tah nepříteli
            endPlayerTurn()
        }
    }

    func playerHeal() {
        guard combatState == .playerTurn else { return }

        // Tady bys kontroloval, jestli má potion. Pro demo dáme free heal.
        let healAmount = 20
        player.stats.hp = min(player.stats.maxHP, player.stats.hp + healAmount)

        addToLog("Použil jsi lektvar. Obnoveno \(healAmount) HP.")
        endPlayerTurn()
    }

    // --- AKCE NEPŘÍTELE (AI) ---

    private func endPlayerTurn() {
        combatState = .enemyTurn

        // Simulace přemýšlení (aby to nebylo instantní)
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 sekundy pauza
            await performEnemyTurn()
        }
    }

    private func performEnemyTurn() {
        // Jednoduchá AI: Prostě útočí
        // Později sem můžeš dát: if enemy.hp < 10 { heal() } else { attack() }

        let baseDmg = max(
            1,
            enemy.combatStats.attack - (player.stats.defense / 2)
        )
        let randomVariation = Int.random(in: -1...3)
        let finalDmg = max(1, baseDmg + randomVariation)

        player.stats.hp -= finalDmg
        playerIsHit = true

        addToLog("\(enemy.name) útočí! Dostal jsi \(finalDmg) poškození.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playerIsHit = false
        }

        // Kontrola prohry
        if player.stats.hp <= 0 {
            player.stats.hp = 0
            loseBattle()
        } else {
            combatState = .playerTurn
            addToLog("Jsi na tahu.")
        }
    }

    // --- KONEC BOJE ---

    private func winBattle() {
        combatState = .victory
        addToLog(
            "VÍTĚZSTVÍ! Získáváš \(enemy.rewards.xp) XP a \(enemy.rewards.coins) zlaťáků."
        )

        // Tady bys volal User.addXP(...) a uložil do Firestore
        player.addXP(enemy.rewards.xp)
        player.addCoins(enemy.rewards.coins)

        onWin?()
    }

    private func loseBattle() {
        combatState = .defeat
        addToLog("Byl jsi poražen...")
    }

    private func addToLog(_ message: String) {
        // Přidáme na začátek pole, aby nahoře byla nejnovější zpráva
        withAnimation {
            battleLog.insert(message, at: 0)
        }
    }
}
