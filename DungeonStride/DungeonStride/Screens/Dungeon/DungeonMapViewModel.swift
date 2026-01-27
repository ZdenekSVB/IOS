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
        guard let user = user, let dungeonId = activeDungeonId else { return }

        let currentProgress = user.dungeonProgress[dungeonId] ?? 0
        var newProgress = currentProgress + 1

        if newProgress > 3 { newProgress = 3 }

        self.user?.dungeonProgress[dungeonId] = newProgress

        db.collection("users").document(user.uid).updateData([
            "dungeonProgress.\(dungeonId)": newProgress
        ])

        print("🎉 Progress v \(dungeonId) zvýšen na \(newProgress)")
    }
}
