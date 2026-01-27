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

    var totalPhysicalAttack: Int = 0
    var totalMagicAttack: Int = 0
    var totalPhysicalDefense: Int = 0
    var totalMagicDefense: Int = 0

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

        self.totalPhysicalAttack = player.stats.physicalDamage
        self.totalPhysicalDefense = player.stats.defense

        self.totalMagicAttack = 0
        self.totalMagicDefense = 0

        addToLog("⚔️ Souboj s \(enemy.name) začíná!")

        Task {
            await loadEquippedStatsAndSpells()  // Spojeno pro efektivitu
            await loadConsumables()
        }
    }

    // --- 1. NAČÍTÁNÍ DAT ---

    func loadEquippedStatsAndSpells() async {
        var loadedSpells: [CombatSpell] = []

        // Reset equip bonusů (základ zůstává z initu)
        var equipPhysAtk = 0
        var equipMagAtk = 0
        var equipPhysDef = 0
        var equipMagDef = 0

        for (_, itemId) in player.equippedIds {
            do {
                let doc = try await db.collection("items").document(itemId)
                    .getDocument()
                if let item = try? doc.data(as: AItem.self) {

                    if item.itemType == "Spell" {
                        loadedSpells.append(CombatSpell(item: item))
                    } else {
                        // Sčítáme nové staty z Item modelu
                        equipPhysAtk += item.finalPhysicalDamage ?? 0
                        equipMagAtk += item.finalMagicDamage ?? 0
                        equipPhysDef += item.finalPhysicalDefense ?? 0
                        equipMagDef += item.finalMagicDefense ?? 0
                    }
                }
            } catch {
                print("Chyba itemu \(itemId): \(error)")
            }
        }

        // Aplikace bonusů
        self.totalPhysicalAttack += equipPhysAtk
        self.totalMagicAttack += equipMagAtk
        self.totalPhysicalDefense += equipPhysDef
        self.totalMagicDefense += equipMagDef

        self.availableSpells = loadedSpells

        print(
            "📊 Stats: PhysAtk \(totalPhysicalAttack), MagAtk \(totalMagicAttack), PhysDef \(totalPhysicalDefense), MagDef \(totalMagicDefense)"
        )
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

        // Rychlý útok: 80% Fyzického útoku vs Fyzická obrana
        let rawDmg = Double(totalPhysicalAttack) * 0.8
        let enemyDef = Double(enemy.combatStats.physicalDefense)

        // Vzorec: (Attack * 0.8) - (EnemyDef / 2)
        let calcDmg = Int(max(1, rawDmg - (enemyDef * 0.5)))

        // Malá variace +-1
        let finalDmg = max(1, calcDmg + Int.random(in: -1...1))

        applyDamageToEnemy(amount: finalDmg)
        addToLog("⚡ Rychlý výpad za \(finalDmg) dmg.")

        actionMenuState = .main
        endPlayerTurn()
    }

    // NOVÉ: Silný útok (silný, ale jsi zranitelný)
    func performHeavyAttack() {
        guard combatState == .playerTurn else { return }

        // Silný útok: 130% Fyzického útoku, ale riskuješ
        let rawDmg = Double(totalPhysicalAttack) * 1.3
        let enemyDef = Double(enemy.combatStats.physicalDefense)

        let calcDmg = Int(max(1, rawDmg - (enemyDef * 0.5)))
        let finalDmg = max(1, calcDmg + Int.random(in: -2...5))

        isVulnerable = true
        applyDamageToEnemy(amount: finalDmg)
        addToLog("💥 DRTIVÝ ÚDER za \(finalDmg) dmg! (Jsi odkrytý)")

        actionMenuState = .main
        endPlayerTurn()
    }

    func castSpell(spell: CombatSpell) {
        guard combatState == .playerTurn else { return }

        // Útočné kouzlo
        if let spellBaseDmg = spell.item.baseStats.magicDamage {  // nebo finalMagicDamage
            // Magický útok: (Spell Base + Player Magic Atk) vs Enemy Magic Def
            let totalPower = Double(
                (spell.item.finalMagicDamage ?? spellBaseDmg) + totalMagicAttack
            )
            let enemyResist = Double(enemy.combatStats.magicDefense)

            let calcDmg = Int(max(1, totalPower - (enemyResist * 0.5)))

            applyDamageToEnemy(amount: calcDmg)
            addToLog(
                "✨ \(spell.item.name) zasáhlo za \(calcDmg) magického dmg!"
            )
        }
        // Léčivé kouzlo
        else if let heal = spell.item.finalHealthBonus {
            let recovered = min(player.stats.maxHP - player.stats.hp, heal)
            player.stats.hp += recovered
            addToLog("💚 \(spell.item.name) vyléčilo \(recovered) HP.")
        }

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

        // Odečíst
        if let index = consumables.firstIndex(where: { $0.id == consumable.id })
        {
            consumables[index].quantity -= 1
            if consumables[index].quantity <= 0 {
                consumables.remove(at: index)
            }
        }
        updateInventoryInDB(
            docId: consumable.id,
            newQuantity: consumable.quantity - 1
        )

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
        // Nepřítel má jak Fyzický, tak Magický útok
        // Hráč má Fyzickou a Magickou obranu

        // 1. Spočítat Fyzickou část
        var physDmg = 0
        if enemy.combatStats.physicalDamage > 0 {
            let raw = Double(enemy.combatStats.physicalDamage)
            let def = Double(totalPhysicalDefense)
            physDmg = max(0, Int(raw - (def * 0.5)))
        }

        // 2. Spočítat Magickou část
        var magicDmg = 0
        if enemy.combatStats.magicDamage > 0 {
            let raw = Double(enemy.combatStats.magicDamage)
            let def = Double(totalMagicDefense)
            magicDmg = max(0, Int(raw - (def * 0.5)))
        }

        var totalIncoming = physDmg + magicDmg
        var msg = "⚠️ \(enemy.name) útočí!"

        // -- Modifikátory --

        // DODGE (Úhyb - funguje na vše, ale 50/50)
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

        // BLOCK (Blok - velmi efektivní proti Fyz, méně proti Magii)
        if isBlocking {
            physDmg /= 2  // 50% redukce fyzického
            magicDmg = Int(Double(magicDmg) * 0.7)  // 30% redukce magického
            totalIncoming = physDmg + magicDmg
            msg = "🛡️ Zablokováno!"
        }

        // VULNERABLE (Zranitelný po Heavy Attack)
        if isVulnerable {
            totalIncoming = Int(Double(totalIncoming) * 1.3)
            msg = "⚠️ Jsi odkrytý! Kritický zásah!"
        }

        // Finální poškození (variance)
        let finalDmg = max(1, totalIncoming + Int.random(in: -1...2))

        player.stats.hp -= finalDmg
        playerIsHit = true

        // Log zpráva podle typu poškození
        if enemy.combatStats.magicDamage > 0
            && enemy.combatStats.physicalDamage > 0
        {
            msg += " (Hybridní útok)"
        } else if enemy.combatStats.magicDamage > 0 {
            msg += " (Magie)"
        }

        addToLog("\(msg) -\(finalDmg) HP")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playerIsHit = false
        }

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
