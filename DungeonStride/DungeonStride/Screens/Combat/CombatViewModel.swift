//
//  CombatViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import FirebaseFirestore
import SwiftUI

enum CombatState {
    case playerTurn
    case enemyTurn
    case victory
    case defeat
}

enum CombatActionState {
    case main
    case attacks
    case items
    case spells
}

struct CombatConsumable: Identifiable {
    let id: String
    let item: AItem
    var quantity: Int
}

struct CombatSpell: Identifiable {
    let id = UUID()
    let item: AItem
}

@MainActor
class CombatViewModel: ObservableObject {
    @Published var player: User
    @Published var enemy: Enemy

    @Published var combatState: CombatState = .playerTurn
    @Published var actionMenuState: CombatActionState = .main
    @Published var battleLog: [String] = []

    @Published var playerIsHit = false
    @Published var enemyIsHit = false

    @Published var consumables: [CombatConsumable] = []
    @Published var availableSpells: [CombatSpell] = []

    var totalAttack: Int = 0
    var totalDefense: Int = 0

    // Stavy v kole
    var isBlocking = false
    var isDodging = false
    var isVulnerable = false  // NOVÉ: Hráč je zranitelný po Silném útoku

    private let db = Firestore.firestore()
    var onWin: (() -> Void)?

    init(player: User, enemy: Enemy, onWin: (() -> Void)? = nil) {
        self.player = player
        self.enemy = enemy
        self.onWin = onWin

        // Základní staty
        self.totalAttack = player.stats.physicalDamage
        self.totalDefense = player.stats.defense

        addToLog("⚔️ Souboj s \(enemy.name) začíná!")

        Task {
            await loadEquippedStatsAndSpells()  // Spojeno pro efektivitu
            await loadConsumables()
        }
    }

    // --- 1. NAČÍTÁNÍ DAT ---

    // Spojil jsem načítání statů a kouzel, protože obojí bere data z equippedIds
    func loadEquippedStatsAndSpells() async {
        var loadedSpells: [CombatSpell] = []

        for (_, itemId) in player.equippedIds {
            do {
                let doc = try await db.collection("items").document(itemId)
                    .getDocument()
                if let item = try? doc.data(as: AItem.self) {

                    if item.itemType == "Spell" {
                        // Je to kouzlo -> přidat do seznamu kouzel
                        loadedSpells.append(CombatSpell(item: item))
                    } else {
                        // Je to výbava -> přičíst staty
                        self.totalAttack += item.finalAttack ?? 0
                        self.totalDefense += item.finalDefense ?? 0
                        print("➕ Equip: \(item.name) (+Atk/Def)")
                    }
                }
            } catch {
                print("Chyba itemu \(itemId): \(error)")
            }
        }
        self.availableSpells = loadedSpells
        print("📊 Stats: Atk \(totalAttack), Def \(totalDefense)")
    }

    func loadConsumables() async {
        guard let uid = player.id else { return }
        do {
            let snapshot = try await db.collection("users").document(uid)
                .collection("inventory").getDocuments()

            var loadedConsumables: [CombatConsumable] = []

            for doc in snapshot.documents {
                let itemId = doc.data()["itemId"] as? String ?? ""
                let quantity = doc.data()["quantity"] as? Int ?? 0

                if quantity > 0 {
                    let itemDoc = try await db.collection("items").document(
                        itemId
                    ).getDocument()
                    if let itemData = try? itemDoc.data(as: AItem.self),
                        itemData.itemType == "Potion"
                            || itemData.itemType == "Consumable"
                    {
                        loadedConsumables.append(
                            CombatConsumable(
                                id: doc.documentID,
                                item: itemData,
                                quantity: quantity
                            )
                        )
                    }
                }
            }
            self.consumables = loadedConsumables
        } catch {
            print("Chyba batohu: \(error)")
        }
    }

    // --- 2. AKCE HRÁČE ---

    // NOVÉ: Rychlý útok (slabší, bezpečný)
    func performQuickAttack() {
        guard combatState == .playerTurn else { return }

        // 80% normálního útoku
        let dmg = Int(
            Double(max(1, totalAttack - (enemy.combatStats.defense / 2))) * 0.8
        )
        let finalDmg = max(1, dmg + Int.random(in: -1...1))

        applyDamageToEnemy(amount: finalDmg)
        addToLog("⚡ Rychlý výpad za \(finalDmg) dmg.")

        actionMenuState = .main
        endPlayerTurn()
    }

    // NOVÉ: Silný útok (silný, ale jsi zranitelný)
    func performHeavyAttack() {
        guard combatState == .playerTurn else { return }

        // 130% normálního útoku
        let dmg = Int(
            Double(max(1, totalAttack - (enemy.combatStats.defense / 2))) * 1.3
        )
        let finalDmg = max(1, dmg + Int.random(in: -2...5))

        isVulnerable = true  // Nastavíme flag zranitelnosti

        applyDamageToEnemy(amount: finalDmg)
        addToLog("💥 DRTIVÝ ÚDER za \(finalDmg) dmg! (Jsi odkrytý)")

        actionMenuState = .main
        endPlayerTurn()
    }

    func performBlock() {
        guard combatState == .playerTurn else { return }
        isBlocking = true
        addToLog("🛡️ Zvedáš obranu.")
        endPlayerTurn()
    }

    func performDodge() {
        guard combatState == .playerTurn else { return }
        isDodging = true
        addToLog("💨 Soustředíš se na úhyb...")
        endPlayerTurn()
    }

    func useConsumable(consumable: CombatConsumable) {
        guard combatState == .playerTurn else { return }

        if let hpBonus = consumable.item.baseStats.healthBonus, hpBonus > 0 {
            let heal = min(player.stats.maxHP - player.stats.hp, hpBonus)
            player.stats.hp += heal
            addToLog("🧪 \(consumable.item.name) (+\(heal) HP)")
        }

        // Update lokálně
        if let index = consumables.firstIndex(where: { $0.id == consumable.id })
        {
            consumables[index].quantity -= 1
            if consumables[index].quantity <= 0 {
                consumables.remove(at: index)
            }
        }
        // Update DB
        updateInventoryInDB(
            docId: consumable.id,
            newQuantity: consumable.quantity - 1
        )

        actionMenuState = .main
        endPlayerTurn()
    }

    func castSpell(spell: CombatSpell) {
        guard combatState == .playerTurn else { return }

        if let dmg = spell.item.baseStats.attack {
            let totalDmg = dmg + player.stats.magicDamage
            applyDamageToEnemy(amount: totalDmg)
            addToLog("🔥 \(spell.item.name) zasáhl za \(totalDmg) dmg!")
        } else if let heal = spell.item.baseStats.healthBonus {
            let recovered = min(player.stats.maxHP - player.stats.hp, heal)
            player.stats.hp += recovered
            addToLog("✨ \(spell.item.name) vyléčilo \(recovered) HP.")
        }

        actionMenuState = .main
        endPlayerTurn()
    }

    // --- 3. POMOCNÉ FUNKCE ---

    private func updateInventoryInDB(docId: String, newQuantity: Int) {
        guard let uid = player.id else { return }
        let ref = db.collection("users").document(uid).collection("inventory")
            .document(docId)
        if newQuantity > 0 {
            ref.updateData(["quantity": newQuantity])
        } else {
            ref.delete()
        }
    }

    func applyDamageToEnemy(amount: Int) {
        enemy.currentHP -= amount
        enemyIsHit = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.enemyIsHit = false
        }

        if enemy.currentHP <= 0 {
            enemy.currentHP = 0
            winBattle()
        }
    }

    // --- 4. TAH NEPŘÍTELE ---

    func endPlayerTurn() {
        if enemy.currentHP <= 0 { return }
        combatState = .enemyTurn
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            performEnemyTurn()
        }
    }

    func performEnemyTurn() {
        var baseDmg = max(1, enemy.combatStats.attack - (totalDefense / 2))
        var msg = "⚠️ \(enemy.name) útočí!"

        // 1. Kontrola DODGE
        if isDodging {
            let dodgeChance = 0.4 + player.stats.evasion
            if Double.random(in: 0...1) < dodgeChance {
                addToLog("💨 USKOČIL JSI! (0 dmg)")
                resetTurnFlags()
                combatState = .playerTurn
                return
            } else {
                msg = "❌ Úhyb nevyšel!"
            }
        }

        // 2. Kontrola VULNERABLE (po silném útoku)
        if isVulnerable {
            baseDmg = Int(Double(baseDmg) * 1.3)  // +30% poškození
            msg = "⚠️ Jsi odkrytý! Kritický zásah!"
        }

        // 3. Kontrola BLOK
        if isBlocking {
            baseDmg = Int(Double(baseDmg) * 0.5)
            msg = "🛡️ Zablokováno!"
        }

        let finalDmg = max(1, baseDmg + Int.random(in: -1...2))

        player.stats.hp -= finalDmg
        playerIsHit = true
        addToLog("\(msg) -\(finalDmg) HP")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playerIsHit = false
        }

        // Reset flagů na konci kola
        resetTurnFlags()

        if player.stats.hp <= 0 {
            player.stats.hp = 0
            loseBattle()
        } else {
            combatState = .playerTurn
        }
    }

    func resetTurnFlags() {
        isBlocking = false
        isDodging = false
        isVulnerable = false
    }

    func addToLog(_ msg: String) {
        withAnimation { battleLog.insert(msg, at: 0) }
    }

    func winBattle() {
        combatState = .victory
        addToLog("🏆 VÍTĚZSTVÍ!")
        onWin?()
    }

    func loseBattle() {
        combatState = .defeat
        addToLog("💀 Byl jsi poražen.")
    }
}
