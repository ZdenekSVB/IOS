//
//  DungeonMapViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

@MainActor
class DungeonMapViewModel: ObservableObject {

    @Published var mapData: GameMap?
    @Published var locations: [GameMapLocation] = []

    @Published var user: User?
    @Published var currentUserLocation: GameMapLocation?
    @Published var userPosition: CGPoint = CGPoint(x: 2000, y: 2000)
    @Published var currentTravelDuration: Double = 0.0

    @Published var isTraveling = false

    @Published var activeDungeonId: String?
    @Published var currentEnemy: Enemy?
    @Published var showCombat = false

    @Published var isRuinsActive: Bool = false
    @Published var ruinsCurrentRoom: Int = 1
    @Published var ruinsMaxRooms: Int = 5
    @Published var currentDoors: [RuinsDoor] = []
    @Published var ruinsLog: String = "Vstupuješ do temných ruin..."

    private let db = Firestore.firestore()

    func loadMapData(mapId: String) async {
        do {
            // 1. Hlavní dokument
            let mapSnapshot = try await db.collection("game_maps").document(
                mapId
            ).getDocument()
            self.mapData = try mapSnapshot.data(as: GameMap.self)

            // 2. Subkolekce
            let locationsSnapshot = try await db.collection("game_maps")
                .document(mapId)
                .collection("locations")
                .getDocuments()

            self.locations = locationsSnapshot.documents.compactMap { doc in
                try? doc.data(as: GameMapLocation.self)
            }

            print("🗺️ Mapa načtena: \(self.locations.count) lokací")

            // Nastavení startovní pozice (pokud ještě není)
            restoreUserPosition()

        } catch {
            print("❌ Chyba mapy: \(error)")
        }
    }

    func loadUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db.collection("users").document(uid)
                .getDocument()

            if let data = snapshot.data() {
                self.user = User.fromFirestore(documentId: uid, data: data)

                restoreUserPosition()
            }
        } catch {
            print("Chyba načítání uživatele: \(error)")
        }
    }

    func respawnUser() {
        guard let user = user else { return }

        db.collection("users").document(user.uid).updateData([
            "isDead": false,
            "deathStats": FieldValue.delete(),
            "stats.hp": user.stats.maxHP,
        ]) { err in
            if let err = err {
                print("❌ Chyba respawnu: \(err)")
            } else {
                print("✨ Hráč úspěšně oživen!")

                // 2. Lokální update UI
                self.user?.isDead = false
                self.user?.deathStats = nil
                self.user?.stats.hp = self.user?.stats.maxHP ?? 100

                // Volitelně: Přesunout do města (safety)
                if let city = self.locations.first(where: {
                    $0.locationType == "city"
                }) {
                    self.travel(to: city)
                }
            }
        }
    }

    func restoreUserPosition() {
        // Musíme mít načtenou mapu i uživatele
        guard let user = user, !locations.isEmpty else { return }

        // Pokud už máme pozici nastavenou (např. při reloadu), neděláme nic,
        // aby panáček neposkakoval.
        if currentUserLocation != nil { return }

        var targetLocation: GameMapLocation?

        // 1. Zkusíme najít uloženou lokaci podle ID (názvu)
        if let savedId = user.currentLocationId, !savedId.isEmpty {
            targetLocation = locations.first(where: { $0.name == savedId })
        }

        // 2. Pokud se nenašla (nebo je nový uživatel), fallback na první město
        if targetLocation == nil {
            targetLocation = locations.first(where: {
                $0.locationType == "city"
            })
        }

        // 3. Nastavíme pozici
        if let target = targetLocation {
            self.currentUserLocation = target
            self.userPosition = target.position
            print("📍 Pozice obnovena na: \(target.name)")
        }
    }

    func travel(to destination: GameMapLocation) {
        guard !isTraveling, currentUserLocation != destination else { return }

        guard let user = user else { return }
        let cost = calculateTravelCost(to: destination)

        if user.distanceBank < cost {
            print(
                "❌ Nemáš dostatek energie! (Potřebuješ \(Int(cost))m, máš \(Int(user.distanceBank))m)"
            )
            return  // Tady by to chtělo vyhodit alert v UI (řešíme níže)
        }

        payForTravel(cost: cost)

        isTraveling = true

        let distance = hypot(
            destination.x - userPosition.x,
            destination.y - userPosition.y
        )
        let speed: Double = 400.0
        let duration = distance / speed

        self.currentTravelDuration = duration
        self.userPosition = destination.position

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.currentUserLocation = destination
            self.isTraveling = false
            print("Dorazil jsi do: \(destination.name)")

            self.saveUserLocation(locationName: destination.name)
        }
    }

    func calculateTravelCost(to destination: GameMapLocation) -> Double {
        let distanceInPoints = hypot(
            destination.x - userPosition.x,
            destination.y - userPosition.y
        )

        let conversionFactor: Double = 1.5
        return distanceInPoints * conversionFactor
    }

    private func payForTravel(cost: Double) {
        guard let uid = user?.id else { return }

        self.user?.distanceBank -= cost
        if (self.user?.distanceBank ?? 0) < 0 { self.user?.distanceBank = 0 }

        db.collection("users").document(uid).updateData([
            "distanceBank": self.user?.distanceBank ?? 0
        ])
    }

    private func saveUserLocation(locationName: String) {
        guard let uid = user?.id else { return }

        // 1. Aktualizujeme lokálně
        self.user?.currentLocationId = locationName

        // 2. Odešleme do Firebase
        db.collection("users").document(uid).updateData([
            "currentLocationId": locationName
        ]) { err in
            if let err = err {
                print("❌ Chyba při ukládání pozice: \(err)")
            } else {
                print("💾 Pozice uložena: \(locationName)")
            }
        }
    }

    func fetchEnemies(ids: [String]) async -> [Enemy]? {
        var loadedEnemies: [Enemy] = []

        for id in ids {
            do {
                let doc = try await db.collection("enemies").document(id)
                    .getDocument()

                if var enemy = try? doc.data(as: Enemy.self) {
                    enemy.id = doc.documentID
                    loadedEnemies.append(enemy)
                }
            } catch {
                print("Chyba při načítání enemy \(id): \(error)")
            }
        }
        return loadedEnemies
    }

    func handleVictory() {
        guard let user = user, let dungeonId = activeDungeonId,
            let defeatedEnemy = currentEnemy
        else { return }

        // 1. Zvýšit progress v dungeonu
        let currentProgress = user.dungeonProgress[dungeonId] ?? 0
        var newProgress = currentProgress + 1
        if newProgress > 3 { newProgress = 3 }

        self.user?.dungeonProgress[dungeonId] = newProgress
        db.collection("users").document(user.uid).updateData([
            "dungeonProgress.\(dungeonId)": newProgress
        ])

        // 2. KONTROLA BOSSE
        // Zjistíme, jestli byl tento enemy POSLEDNÍ v seznamu pro danou lokaci
        if let currentLoc = locations.first(where: { $0.name == dungeonId }),
            let enemyList = currentLoc.enemyIds,
            let lastEnemyId = enemyList.last
        {

            // Porovnáváme ID (nebo jméno/iconName, podle toho co používáš jako ID)
            // V tvém JSONu enemyIds odpovídají iconName/ID
            if defeatedEnemy.id == lastEnemyId
                || defeatedEnemy.iconName == lastEnemyId
            {
                print("🔥 BOSS PORAŽEN: \(defeatedEnemy.name)")
                handleBossLoot(
                    bossName: defeatedEnemy.name,
                    bossId: lastEnemyId
                )
            }
        }
    }

    // ----- RUINS -----

    func enterRuins(location: GameMapLocation) {
        self.activeDungeonId = location.name
        self.ruinsCurrentRoom = 1
        self.ruinsMaxRooms = 3 + (location.difficultyTier ?? 1)
        self.ruinsLog = "Vstoupil jsi do: \(location.name)"
        self.isRuinsActive = true

        generateDoors()
    }

    func generateDoors() {
        if ruinsCurrentRoom > ruinsMaxRooms {
            completeRuins()
            return
        }

        if ruinsCurrentRoom == ruinsMaxRooms {
            self.currentDoors = [RuinsDoor(type: .boss)]
            self.ruinsLog = "Cítíš přítomnost silného nepřítele..."
            return
        }

        var newDoors: [RuinsDoor] = []
        for _ in 0..<3 {
            newDoors.append(RuinsDoor(type: pickRandomDoorType()))
        }
        self.currentDoors = newDoors
    }

    private func pickRandomDoorType() -> RuinsDoorType {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1...30: return .combat  // 30% Boj
        case 31...50: return .treasure  // 20% Poklad
        case 51...65: return .item  // 15% Item
        case 66...85: return .trap  // 20% Trap
        default: return .heal  // 15% Heal
        }
    }

    func selectDoor(door: RuinsDoor) {
        if door.isRevealed { return }

        // 1. Odhalit dveře (V UI se spustí animace)
        if let index = currentDoors.firstIndex(where: { $0.id == door.id }) {
            withAnimation {
                currentDoors[index].isRevealed = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.resolveDoorEffect(door: door)
        }
    }

    private func resolveDoorEffect(door: RuinsDoor) {
        switch door.type {
        case .combat:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleRuinsCombat(isBoss: false)
            }
        case .boss:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleRuinsCombat(isBoss: true)
            }
        case .treasure:
            // Čím vyšší room, tím víc goldů
            let multiplier = Double(ruinsCurrentRoom) * 0.5 + 1.0
            let gold = Int(Double(Int.random(in: 20...100)) * multiplier)
            user?.coins += gold
            updateRuinsLog(msg: "💰 Našel jsi \(gold) zlaťáků!")
            prepareNextRoom(delay: 2.0)

        case .item:
            // 🆕 PROGRESIVNÍ LOOT Z TRUHLY
            updateRuinsLog(msg: "Otevíráš starou truhlu...")
            Task {
                // Určíme raritu podle aktuální místnosti a max místností
                let rarity = determineLootRarity()

                if let item = await fetchRandomItem(rarity: rarity) {
                    addItemToInventory(item: item)
                    updateRuinsLog(
                        msg: "🎒 Získal jsi: \(item.name) (\(item.rarity))"
                    )
                } else {
                    updateRuinsLog(msg: "Truhla byla prázdná.")
                }
                prepareNextRoom(delay: 2.5)
            }

        case .trap:
            // Pasti jsou silnější v pozdějších levelech
            let baseDmg = Int.random(in: 10...20)
            let dmg = baseDmg + (ruinsCurrentRoom * 5)

            user?.stats.hp -= dmg
            if (user?.stats.hp ?? 0) < 0 { user?.stats.hp = 0 }

            updateRuinsLog(msg: "⚠️ Past! Ztratil jsi \(dmg) HP.")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            if (user?.stats.hp ?? 0) <= 0 {
                isRuinsActive = false
            } else {
                prepareNextRoom(delay: 2.5)
            }

        case .heal:
            let heal = 30 + (ruinsCurrentRoom * 5)
            let max = user?.stats.maxHP ?? 100
            user?.stats.hp = min(max, (user?.stats.hp ?? 0) + heal)
            updateRuinsLog(msg: "💚 Studánka tě vyléčila (+\(heal) HP).")
            prepareNextRoom(delay: 2.0)
        }

        if let u = user {
            db.collection("users").document(u.uid).updateData([
                "coins": u.coins,
                "stats.hp": u.stats.hp,
            ])
        }
    }

    private func handleRuinsCombat(isBoss: Bool) {
        guard let locName = activeDungeonId,
            let loc = locations.first(where: { $0.name == locName }),
            let enemyIds = loc.enemyIds, !enemyIds.isEmpty
        else {
            updateRuinsLog(msg: "Nikdo tu není.")
            prepareNextRoom()
            return
        }

        let enemyId: String
        if isBoss {
            enemyId = enemyIds.last!
        } else {
            if enemyIds.count > 1 {
                // Vybereme náhodného, ale ne posledního (Bosse)
                enemyId = enemyIds.dropLast().randomElement()!
            } else {
                enemyId = enemyIds.first!
            }
        }

        Task {
            if let enemies = await fetchEnemies(ids: [enemyId]),
                let enemy = enemies.first
            {
                self.currentEnemy = enemy
                self.showCombat = true
            }
        }
    }

    func prepareNextRoom(delay: Double = 1.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.ruinsCurrentRoom <= self.ruinsMaxRooms {
                self.ruinsLog = "Jdeš hlouběji do ruin..."
            }
            withAnimation {
                self.ruinsCurrentRoom += 1
                self.generateDoors()
            }
        }
    }

    func completeRuins() {
        self.ruinsLog = "🎉 Ruiny vyčištěny!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isRuinsActive = false
        }
    }

    private func updateRuinsLog(msg: String) {
        withAnimation { self.ruinsLog = msg }
    }

    private func fetchRandomItem(rarity: String) async -> AItem? {
        do {
            // Stáhneme items dané rarity (limit 20 pro variabilitu)
            let snapshot = try await db.collection("items")
                .whereField("rarity", isEqualTo: rarity)
                .limit(to: 20)
                .getDocuments()

            let items = snapshot.documents.compactMap {
                try? $0.data(as: AItem.self)
            }
            return items.randomElement()
        } catch {
            print("Chyba loot: \(error)")
            return nil
        }
    }

    private func determineLootRarity() -> String {
        let progress = Double(ruinsCurrentRoom) / Double(ruinsMaxRooms)
        let roll = Int.random(in: 1...100)

        // Začátek (do 30%): Hlavně Common, šance na Uncommon
        if progress < 0.3 {
            return roll > 80 ? "Uncommon" : "Common"
        }
        // Střed (do 60%): Uncommon, šance na Rare
        else if progress < 0.6 {
            if roll > 90 { return "Rare" }
            return roll > 40 ? "Uncommon" : "Common"
        }
        // Konec (do 90%): Rare, šance na Epic
        else if progress < 0.9 {
            if roll > 85 { return "Epic" }
            return roll > 30 ? "Rare" : "Uncommon"
        }
        // Finále (Boss room / Předposlední): Epic / Legendary šance
        else {
            if roll > 90 { return "Legendary" }
            return "Epic"
        }
    }

    private func fetchItemByNameOrId(_ identifier: String) async -> AItem? {
        do {
            let doc = try await db.collection("items").document(identifier)
                .getDocument()
            if let item = try? doc.data(as: AItem.self) {
                return item
            }

            // Pokud nenajdeme podle ID, zkusíme query podle 'name'
            let query = try await db.collection("items")
                .whereField("name", isEqualTo: identifier)
                .limit(to: 1)
                .getDocuments()

            return query.documents.first.flatMap {
                try? $0.data(as: AItem.self)
            }

        } catch {
            return nil
        }
    }

    private func handleBossLoot(bossName: String, bossId: String) {
        Task {
            var droppedItem: AItem? = nil

            // 1. Specifické dropy pro Bosse (Podle ID nebo Jména)
            switch bossId {
            case "AncientRedDragon":
                // Zkusíme stáhnout první item, pokud selže, zkusíme druhý
                if let item = await fetchItemByNameOrId("DragonscaleMail") {
                    droppedItem = item
                } else {
                    droppedItem = await fetchItemByNameOrId("DragonVisage")
                }

            case "LichLord":
                if let item = await fetchItemByNameOrId("CrownOfTheLich") {
                    droppedItem = item
                } else {
                    droppedItem = await fetchItemByNameOrId("StaffOfTheVoid")
                }

            case "Broodmother":
                droppedItem = await fetchItemByNameOrId("BroodmothersFang")

            case "DeepSeaTerror":
                droppedItem = await fetchItemByNameOrId("TridentOfTheDeep")

            case "BanditLeader":
                droppedItem = await fetchItemByNameOrId("AssassinsBlade")

            case "InfernalDemon":
                droppedItem = await fetchItemByNameOrId("DemonScythe")

            case "CorruptedTreant":
                droppedItem = await fetchItemByNameOrId("HeartOfTheForest")

            default:
                break
            }

            // 2. Fallback: Náhodný Legendary/Epic
            if droppedItem == nil {
                print("🎲 Boss drop fallback...")
                let rarity = Bool.random() ? "Legendary" : "Epic"
                droppedItem = await fetchRandomItem(rarity: rarity)
            }

            // 3. Přidat
            if let item = droppedItem {
                addItemToInventory(item: item)

                await MainActor.run {
                    if isRuinsActive {
                        self.updateRuinsLog(msg: "🌟 BOSS DROP: \(item.name)!")
                    }
                }
            }
        }
    }
    
    private func addItemToInventory(item: AItem) {
        guard let uid = user?.id, let itemId = item.id else { return }

        let inventoryRef = db.collection("users").document(uid).collection(
            "inventory"
        ).document(itemId)

        inventoryRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                inventoryRef.updateData([
                    "quantity": FieldValue.increment(Int64(1))
                ])
            } else {
                inventoryRef.setData([
                    "itemId": itemId,
                    "quantity": 1,
                    "equipped": false,
                    "acquiredAt": FieldValue.serverTimestamp(),
                ])
            }
            print("🎒 Item přidán: \(item.name)")
        }
    }

}
