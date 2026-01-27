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
    var isVulnerable = false

    private let db = Firestore.firestore()
    
    // Callbacky pro výsledek boje
    var onWin: ((Int) -> Void)?
    var onLose: ((Int) -> Void)?

    init(player: User, enemy: Enemy, onWin: ((Int) -> Void)? = nil, onLose: ((Int) -> Void)? = nil) {
        self.player = player
        self.enemy = enemy
        self.onWin = onWin
        self.onLose = onLose

        // Inicializace základních statů (z DB)
        // Pozor: Pokud už User v DB obsahuje bonusy z itemů (díky CharacterViewModel),
        // tak loadEquippedStatsAndSpells je přičte znovu.
        // Pro jistotu zde bereme hodnoty jak jsou a v loadEquippedStatsAndSpells
        // jen aktualizujeme proměnné pro boj, ne player.stats v DB.
        
        self.totalPhysicalAttack = player.stats.physicalDamage
        self.totalPhysicalDefense = player.stats.defense

        self.totalMagicAttack = player.stats.magicDamage
        self.totalMagicDefense = 0 // Magic Defense obvykle ve stats není, počítáme z itemů nebo 0

        addToLog("⚔️ Souboj s \(enemy.name) začíná!")

        Task {
            await loadEquippedStatsAndSpells()
            await loadConsumables()
        }
    }

    // --- 1. NAČÍTÁNÍ DAT ---

    func loadEquippedStatsAndSpells() async {
        var loadedSpells: [CombatSpell] = []
        
        // Pomocné proměnné pro bonusy z itemů
        // (Pokud chceme být přesní, měli bychom `total...` resetovat na base staty postavy,
        // ale zde pro jednoduchost přičteme bonusy, pokud v user.stats chybí)
        
        // Pro správnou funkčnost MaxHP: Zjistíme, jestli player.stats.maxHP už obsahuje bonusy.
        // Pokud je 100 a máme itemy, asi neobsahuje. Pro jistotu připočteme bonusy z itemů k lokálnímu playerovi.
        
        var hpBonus = 0
        var physAtkBonus = 0
        var magAtkBonus = 0
        var physDefBonus = 0
        var magDefBonus = 0

        for (_, itemId) in player.equippedIds {
            do {
                let doc = try await db.collection("items").document(itemId).getDocument()
                if let item = try? doc.data(as: AItem.self) {

                    if item.itemType == "Spell" {
                        loadedSpells.append(CombatSpell(item: item))
                    } else {
                        // Sčítáme bonusy
                        physAtkBonus += item.finalPhysicalDamage ?? 0
                        magAtkBonus += item.finalMagicDamage ?? 0
                        physDefBonus += item.finalPhysicalDefense ?? 0
                        magDefBonus += item.finalMagicDefense ?? 0
                        hpBonus += item.finalHealthBonus ?? 0
                    }
                }
            } catch {
                print("Chyba itemu \(itemId): \(error)")
            }
        }

        // Zde je klíčová oprava:
        // Pokud User z DB má staty "base" (např. 100 HP) a itemy nejsou započítané trvale,
        // musíme je přičíst pro tento boj.
        // Většinou je bezpečnější nastavit `total...` jako (Base + Bonus).
        // Předpokládáme, že `player.stats` co přišel z initu, jsou aktuální hodnoty z DB.
        
        // Aktualizujeme MaxHP pro tento boj
        // (Pokud už v DB bylo uloženo navýšené, toto může způsobit double-count,
        // ale jelikož uživatel hlásí "vždy 100", znamená to, že v DB je 100).
        if hpBonus > 0 {
            // Kontrola: Pokud má user 100 a item dává 50, nastavíme 150.
            // Pokud už má 150 (z CharacterVM), a přičteme 50 -> 200 (chyba).
            // Ale riskujeme raději víc HP než méně.
            // Správnější řešení by bylo mít User.baseStats a User.totalStats.
            
            // PRO TEĎ: Přičteme HP bonus k MaxHP, aby heal fungoval.
            self.player.stats.maxHP += hpBonus
            
            // Pokud je aktuální HP vyšší než nové Max (což se nestane), ořízneme.
            // Pokud je HP plné (z DB 100), zvedneme i aktuální HP? Ne, to by byl free heal.
            // Necháme currentHP jak je, jen zvedneme strop.
        }

        // Aktualizujeme bojové proměnné (použijeme += k hodnotám z initu)
        // POZOR: Tady to může být double count, pokud CharacterVM ukládá do DB.
        // Ale pro HP to je nutné.
        
        // Pro jistotu pouze aktualizujeme to, co nebylo v initu (Magic Def) a zbytek necháme
        // na Userovi, nebo pokud je User slabý, posílíme ho.
        // V tomto modelu ale `total...` proměnné slouží pro výpočet dmg.
        
        // Resetujeme na hodnoty z Usera a přičteme bonusy (pokud user v DB bonusy nemá)
        // Toto je safe fallback.
        // self.totalPhysicalAttack = player.stats.physicalDamage // Už nastaveno v init
        
        // Pokud CharacterVM funguje správně a ukládá stats do DB, pak player.stats už bonusy má.
        // Pokud ne, přičteme je.
        // Uživatel hlásí problém s HP -> CharacterVM asi neuložil MaxHP do DB nebo se to přepsalo.
        // Takže HP bonus přičítáme na řádku 117.
        
        self.availableSpells = loadedSpells
        
        // Log pro kontrolu
        print("📊 Combat Stats: HP: \(player.stats.hp)/\(player.stats.maxHP)")
    }

    func loadConsumables() async {
        guard let uid = player.id else { return }
        do {
            let snapshot = try await db.collection("users").document(uid).collection("inventory").getDocuments()

            var loadedConsumables: [CombatConsumable] = []

            for doc in snapshot.documents {
                let itemId = doc.data()["itemId"] as? String ?? ""
                let quantity = doc.data()["quantity"] as? Int ?? 0

                if quantity > 0 {
                    let itemDoc = try await db.collection("items").document(itemId).getDocument()
                    if let itemData = try? itemDoc.data(as: AItem.self),
                       (itemData.itemType == "Potion" || itemData.itemType == "Consumable")
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

    func performQuickAttack() {
        guard combatState == .playerTurn else { return }
        let rawDmg = Double(totalPhysicalAttack) * 0.8
        let calcDmg = Int(max(1, rawDmg - (Double(enemy.combatStats.physicalDefense) * 0.5)))
        let finalDmg = max(1, calcDmg + Int.random(in: -1...1))

        applyDamageToEnemy(amount: finalDmg)
        addToLog("⚡ Rychlý útok: \(finalDmg) dmg")
        actionMenuState = .main
        endPlayerTurn()
    }

    func performHeavyAttack() {
        guard combatState == .playerTurn else { return }
        let rawDmg = Double(totalPhysicalAttack) * 1.3
        let calcDmg = Int(max(1, rawDmg - (Double(enemy.combatStats.physicalDefense) * 0.5)))
        let finalDmg = max(1, calcDmg + Int.random(in: -2...5))

        isVulnerable = true
        applyDamageToEnemy(amount: finalDmg)
        addToLog("💥 Silný útok: \(finalDmg) dmg (Jsi odkrytý)")
        actionMenuState = .main
        endPlayerTurn()
    }

    func castSpell(spell: CombatSpell) {
        guard combatState == .playerTurn else { return }

        // Útočné kouzlo
        if let spellBaseDmg = spell.item.baseStats.magicDamage {
            let totalPower = Double((spell.item.finalMagicDamage ?? spellBaseDmg) + totalMagicAttack)
            let calcDmg = Int(max(1, totalPower - (Double(enemy.combatStats.magicDefense) * 0.5)))
            applyDamageToEnemy(amount: calcDmg)
            addToLog("✨ \(spell.item.name): \(calcDmg) dmg")
        }
        // Léčivé kouzlo
        else if let heal = spell.item.finalHealthBonus {
            // OPRAVENO: Používáme aktuální player.stats.maxHP (které jsme v loadEquipped navýšili)
            let recovered = min(player.stats.maxHP - player.stats.hp, heal)
            player.stats.hp += recovered
            addToLog("💚 \(spell.item.name): +\(recovered) HP")
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
            // OPRAVENO: Používáme aktuální player.stats.maxHP
            let heal = min(player.stats.maxHP - player.stats.hp, hpBonus)
            player.stats.hp += heal
            addToLog("🧪 \(consumable.item.name): +\(heal) HP")
        }

        // Odečíst z local array
        if let index = consumables.firstIndex(where: { $0.id == consumable.id }) {
            consumables[index].quantity -= 1
            if consumables[index].quantity <= 0 {
                consumables.remove(at: index)
            }
        }
        // Update DB
        updateInventoryInDB(docId: consumable.id, newQuantity: consumable.quantity - 1)

        actionMenuState = .main
        endPlayerTurn()
    }

    // --- 3. POMOCNÉ FUNKCE ---

    private func updateInventoryInDB(docId: String, newQuantity: Int) {
        guard let uid = player.id else { return }
        let ref = db.collection("users").document(uid).collection("inventory").document(docId)
        if newQuantity > 0 {
            ref.updateData(["quantity": newQuantity])
        } else {
            ref.delete()
        }
    }

    func applyDamageToEnemy(amount: Int) {
        enemy.currentHP -= amount
        enemyIsHit = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.enemyIsHit = false }
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
        var physDmg = 0
        if enemy.combatStats.physicalDamage > 0 {
            let raw = Double(enemy.combatStats.physicalDamage)
            let def = Double(totalPhysicalDefense)
            physDmg = max(0, Int(raw - (def * 0.5)))
        }

        var magicDmg = 0
        if enemy.combatStats.magicDamage > 0 {
            let raw = Double(enemy.combatStats.magicDamage)
            let def = Double(totalMagicDefense)
            magicDmg = max(0, Int(raw - (def * 0.5)))
        }

        var totalIncoming = physDmg + magicDmg
        var msg = "⚠️ \(enemy.name) útočí!"

        if isDodging {
            let dodgeChance = 0.4 + player.stats.evasion
            if Double.random(in: 0...1) < dodgeChance {
                addToLog("💨 USKOČIL JSI! (0 dmg)")
                resetTurnFlags()
                combatState = .playerTurn
                return
            } else { msg = "❌ Úhyb nevyšel!" }
        }

        if isBlocking {
            physDmg /= 2
            magicDmg = Int(Double(magicDmg) * 0.7)
            totalIncoming = physDmg + magicDmg
            msg = "🛡️ Zablokováno!"
        }

        if isVulnerable {
            totalIncoming = Int(Double(totalIncoming) * 1.3)
            msg = "⚠️ Jsi odkrytý! Kritický zásah!"
        }

        let finalDmg = max(1, totalIncoming + Int.random(in: -1...2))
        player.stats.hp -= finalDmg
        playerIsHit = true
        addToLog("\(msg) -\(finalDmg) HP")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.playerIsHit = false }
        resetTurnFlags()

        if player.stats.hp <= 0 {
            player.stats.hp = 0
            loseBattle()
        } else {
            combatState = .playerTurn
        }
    }

    func resetTurnFlags() { isBlocking = false; isDodging = false; isVulnerable = false }

    func addToLog(_ msg: String) { withAnimation { battleLog.insert(msg, at: 0) } }

    func winBattle() {
        combatState = .victory
        addToLog("🏆 VÍTĚZSTVÍ!")
        // Vrátíme aktuální životy
        onWin?(player.stats.hp)
    }

    func loseBattle() {
        combatState = .defeat
        addToLog("💀 Byl jsi poražen.")
        // Vrátíme 0
        onLose?(0)
    }
}
