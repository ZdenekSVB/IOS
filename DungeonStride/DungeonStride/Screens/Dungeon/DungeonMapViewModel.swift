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
            let mapSnapshot = try await db.collection("game_maps").document(
                mapId
            ).getDocument()
            self.mapData = try mapSnapshot.data(as: GameMap.self)

            let locationsSnapshot = try await db.collection("game_maps")
                .document(mapId)
                .collection("locations")
                .getDocuments()

            self.locations = locationsSnapshot.documents.compactMap { doc in
                try? doc.data(as: GameMapLocation.self)
            }

            if currentUserLocation == nil {
                if let startNode = self.locations.first(where: {
                    $0.locationType == "city"
                }) {
                    self.currentUserLocation = startNode
                    self.userPosition = startNode.position
                }
            }

        } catch {
            print("Chyba mapy: \(error)")
        }
    }

    func loadUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db.collection("users").document(uid)
                .getDocument()

            if let data = snapshot.data() {
                self.user = User.fromFirestore(documentId: uid, data: data)
            }
        } catch {
            print("Chyba načítání uživatele: \(error)")
        }
    }

    func travel(to destination: GameMapLocation) {
        guard !isTraveling, currentUserLocation != destination else { return }

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
        }
    }

    func fetchEnemies(ids: [String]) async -> [Enemy]? {
        var loadedEnemies: [Enemy] = []

        for id in ids {
            do {
                let doc = try await db.collection("enemies").document(id)
                    .getDocument()
                if let enemy = try? doc.data(as: Enemy.self) {
                    loadedEnemies.append(enemy)
                }
            } catch {
                print("Chyba při načítání enemy \(id): \(error)")
            }
        }
        // Seřadíme je podle pořadí v poli IDs (Firestore to může vrátit napřeskáčku)
        // Ale pro jednoduchost vracíme takto:
        return loadedEnemies
    }

    // PŘIDAT: Funkce volaná po vítězství
    func handleVictory() {
        guard let user = user, let dungeonId = activeDungeonId else { return }

        // 1. Zvedneme progress
        let currentProgress = user.dungeonProgress[dungeonId] ?? 0
        var newProgress = currentProgress + 1

        // Omezíme to na max 3 (pokud máme jen 3 stage)
        if newProgress > 3 { newProgress = 3 }

        // 2. Lokální update
        self.user?.dungeonProgress[dungeonId] = newProgress

        // 3. Firestore update
        db.collection("users").document(user.uid).updateData([
            "dungeonProgress.\(dungeonId)": newProgress
        ])

        print("🎉 Progress v \(dungeonId) zvýšen na \(newProgress)")
    }
}
