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

    func handleVictory(enemy: Enemy? = nil) {
        guard let user = user, let dungeonId = activeDungeonId else { return }

        let currentProgress = user.dungeonProgress[dungeonId] ?? 0
        var newProgress = currentProgress + 1

        if newProgress > 3 { newProgress = 3 }

        self.user?.dungeonProgress[dungeonId] = newProgress

        db.collection("users").document(user.uid).updateData([
            "dungeonProgress.\(dungeonId)": newProgress
        ])

        print("🎉 Progress v \(dungeonId) zvýšen na \(newProgress)")

        if isRuinsActive, ruinsCurrentRoom == ruinsMaxRooms,
            let defeatedEnemy = enemy
        {
            print("🐉 Boss poražen! Generuji odměnu...")
            generateBossLoot(bossName: defeatedEnemy.name)
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
            // Krátká pauza na "leknutí", pak start
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleRuinsCombat(isBoss: false)
            }

        case .boss:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleRuinsCombat(isBoss: true)
            }

        case .treasure:
            let gold = Int.random(in: 20...100)
            user?.coins += gold
            updateRuinsLog(msg: "💰 Našel jsi \(gold) zlaťáků!")
            // Delší pauza na čtení odměny
            prepareNextRoom(delay: 2.0)

        case .item:
            updateRuinsLog(msg: "Otevíráš starou truhlu...")
            Task {
                if let item = await fetchRandomItem(
                    rarity: ["Common", "Uncommon"].randomElement()!
                ) {
                    addItemToInventory(
                        itemId: item.id ?? "",
                        itemName: item.name
                    )
                    updateRuinsLog(msg: "🎒 Získal jsi: \(item.name)!")
                } else {
                    updateRuinsLog(msg: "Truhla byla prázdná.")
                }
                prepareNextRoom(delay: 2.5)
            }

        case .trap:
            let dmg = Int.random(in: 10...30)
            user?.stats.hp -= dmg
            if (user?.stats.hp ?? 0) < 0 { user?.stats.hp = 0 }

            updateRuinsLog(msg: "⚠️ Auu! Past ti ubrala \(dmg) HP.")

            // Otřesení obrazovky (Haptika by byla super)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            if (user?.stats.hp ?? 0) <= 0 {
                // Smrt řešíme hned
                isRuinsActive = false
                // Tady by se měla zavolat logika smrti, ale to se stane asi až v combatu...
                // Pokud umře na past, musíš to handlovat.
                // Prozatím jen zavřeme ruiny a necháme ho s 0 HP (což triggerne Revival v MapView)
            } else {
                prepareNextRoom(delay: 2.5)
            }

        case .heal:
            let heal = 30
            let max = user?.stats.maxHP ?? 100
            user?.stats.hp = min(max, (user?.stats.hp ?? 0) + heal)
            updateRuinsLog(msg: "💚 Cítíš úlevu... (+\(heal) HP).")
            prepareNextRoom(delay: 2.0)
        }

        // Save
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
            // Pokud ještě nejsme na konci
            if self.ruinsCurrentRoom <= self.ruinsMaxRooms {
                self.ruinsLog = "Jdeš hlouběji do ruin..."
            }

            // Krátký fade out efekt dveří?
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
            let snapshot = try await db.collection("items")
                .whereField("rarity", isEqualTo: rarity)
                .limit(to: 10)
                .getDocuments()

            let items = snapshot.documents.compactMap {
                try? $0.data(as: AItem.self)
            }
            return items.randomElement()
        } catch {
            print("Chyba při fetchování itemu: \(error)")
            return nil
        }
    }

    private func addItemToInventory(itemId: String, itemName: String) {
        guard let uid = user?.id, !itemId.isEmpty else { return }

        let inventoryRef = db.collection("users").document(uid).collection(
            "inventory"
        ).document(itemId)

        // Použijeme transakci nebo update (pro jednoduchost update s incrementem)
        // Pokud dokument neexistuje, musíme ho vytvořit
        inventoryRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                // Item už má, zvýšíme počet
                inventoryRef.updateData([
                    "quantity": FieldValue.increment(Int64(1))
                ])
            } else {
                // Item nemá, vytvoříme nový
                inventoryRef.setData([
                    "itemId": itemId,
                    "quantity": 1,
                    "equipped": false,
                    "acquiredAt": FieldValue.serverTimestamp(),
                ])
            }
            print("🎒 Item přidán: \(itemName)")
        }
    }

}
