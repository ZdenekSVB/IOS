//
//  DungeonMapViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class DungeonMapViewModel: ObservableObject {

    // MARK: - State
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    // Data Mapy
    @Published var mapName: String = ""
    @Published var mapImageName: String = ""
    @Published var mapSize: CGSize = CGSize(width: 1000, height: 1000)

    // Obsah Mapy
    @Published var locations: [GameMapLocation] = []
    @Published var paths: [PathConnection] = []  // Na začátku PRÁZDNÉ (žádné čáry)
    @Published var playerPosition: CGPoint = CGPoint(x: 2000, y: 2000)

    // Interakce
    @Published var selectedLocation: GameMapLocation? = nil

    // Aktivní cesta pro animaci (když je nil, nic se nehýbe)
    @Published var travelPath: PathConnection? = nil

    private var db = Firestore.firestore()

    init() {
        loadInitialMap()
    }

    // MARK: - Načítání dat
    func loadInitialMap() {
        print("🗺️ ViewModel: Začínám načítat mapu...")
        self.isLoading = true
        self.errorMessage = nil

        // ID mapy, kterou jsi nahrál přes Seeder
        let targetMapId = "map_ytonga_001"

        db.collection("game_maps").document(targetMapId).getDocument {
            [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Chyba stahování mapy: \(error.localizedDescription)")
                self.handleError(
                    "Chyba načítání mapy: \(error.localizedDescription)"
                )
                return
            }

            guard let document = snapshot, document.exists else {
                print("⚠️ Mapa '\(targetMapId)' neexistuje.")
                self.handleError(
                    "Mapa nebyla nalezena. Zkus v Obchodě kliknout na 'UPLOAD MAPS'."
                )
                return
            }

            do {
                let map = try document.data(as: GameMap.self)
                self.configureMap(with: map)
                self.loadLocations(for: document.documentID)
            } catch {
                print("❌ Chyba dekódování mapy: \(error)")
                self.handleError(
                    "Chyba dat mapy: \(error.localizedDescription)"
                )
            }
        }
    }

    private func configureMap(with map: GameMap) {
        DispatchQueue.main.async {
            self.mapName = map.name
            self.mapImageName = map.imageName
            self.mapSize = map.size
            // Startovní pozice uprostřed (nebo načtená z DB uživatele)
            self.playerPosition = CGPoint(x: map.width / 2, y: map.height / 2)
        }
    }

    private func loadLocations(for mapId: String) {
        db.collection("game_maps").document(mapId).collection("locations")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print(
                        "❌ Chyba stahování lokací: \(error.localizedDescription)"
                    )
                    self.handleError(
                        "Chyba lokací: \(error.localizedDescription)"
                    )
                    return
                }

                let loadedLocations = (snapshot?.documents ?? []).compactMap {
                    try? $0.data(as: GameMapLocation.self)
                }

                print("✅ Načteno \(loadedLocations.count) lokací.")

                DispatchQueue.main.async {
                    self.locations = loadedLocations

                    // DŮLEŽITÉ: Negenrujeme žádné náhodné cesty. Mapa je čistá.
                    self.paths = []

                    self.isLoading = false
                }
            }
    }

    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.isLoading = false
        }
    }

    // MARK: - User Actions

    func selectLocation(_ location: GameMapLocation) {
        self.selectedLocation = location
    }

    // Funkce volaná z Bottom Sheetu ("Cestovat sem")
    func travelToSelectedLocation() {
        guard let target = selectedLocation else { return }

        print("🚶 Cestuji do: \(target.name)")

        // 1. Vytvoříme dynamickou cestu od hráče k cíli
        // CurveAmount 0.2 udělá hezký jemný oblouk
        let newPath = PathConnection(
            from: self.playerPosition,
            to: target.position,
            curveAmount: 0.2
        )

        // 2. Nastavíme travelPath -> To spustí animaci ve View (MapUIKitWrapper)
        self.travelPath = newPath

        // 3. Počkáme 2 sekundy (délka animace), pak aktualizujeme skutečnou pozici
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Hráč "došel"
            self.playerPosition = target.position
            self.travelPath = nil  // Vypneme animaci (čára zmizí)

            // Pokud chceš, aby za hráčem zůstala čára ("prozkoumaná cesta"),
            // můžeš odkomentovat toto:
            // self.paths.append(newPath)
        }

        // Zavřeme sheet
        self.selectedLocation = nil
    }
}
