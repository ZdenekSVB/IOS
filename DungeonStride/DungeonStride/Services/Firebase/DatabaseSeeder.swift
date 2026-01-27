//
//  DatabaseSeeder.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 17.12.2025.
//

import FirebaseFirestore
import SwiftUI

class DatabaseSeeder {

    private let db = Firestore.firestore()

    // --- 1. NAHRÁVÁNÍ PŘEDMĚTŮ (ITEMS) ---
    func uploadItems() async {
        guard
            let url = Bundle.main.url(
                forResource: "items",
                withExtension: "json"
            )
        else {
            print("❌ Soubor items.json nebyl nalezen!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard
                let jsonArray = try JSONSerialization.jsonObject(
                    with: data,
                    options: []
                ) as? [[String: Any]]
            else {
                print("❌ Chyba: items.json má špatný formát.")
                return
            }

            let batch = db.batch()
            var count = 0

            for itemDict in jsonArray {
                guard let name = itemDict["name"] as? String else { continue }

                // ID: "Knight's Sword" -> "knights_sword"
                let docId = generateSnakeCaseId(from: name)

                let docRef = db.collection("items").document(docId)
                batch.setData(itemDict, forDocument: docRef)
                count += 1
            }

            try await batch.commit()
            print("✅ Items: Úspěšně nahráno \(count) předmětů.")

        } catch {
            print("❌ Chyba Items: \(error.localizedDescription)")
        }
    }

    // --- 2. NAHRÁVÁNÍ NEPŘÁTEL (ENEMIES) ---
    func uploadEnemies() async {
        guard
            let url = Bundle.main.url(
                forResource: "enemies",
                withExtension: "json"
            )
        else {
            print("❌ Soubor enemies.json nebyl nalezen!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard
                let jsonArray = try JSONSerialization.jsonObject(
                    with: data,
                    options: []
                ) as? [[String: Any]]
            else {
                print("❌ Chyba: enemies.json má špatný formát.")
                return
            }

            let batch = db.batch()
            var count = 0

            for enemyDict in jsonArray {
                guard let name = enemyDict["name"] as? String else { continue }

                // DŮLEŽITÉ: ID dokumentu musí být "GreenSlime" (bez mezer),
                // aby odpovídalo tomu, co máme v mapě v poli `enemyIds`.
                let docId = name.replacingOccurrences(of: " ", with: "")

                let docRef = db.collection("enemies").document(docId)
                batch.setData(enemyDict, forDocument: docRef)
                count += 1
            }

            try await batch.commit()
            print("✅ Enemies: Úspěšně nahráno \(count) monster.")

        } catch {
            print("❌ Chyba Enemies: \(error.localizedDescription)")
        }
    }

    // --- 3. NAHRÁVÁNÍ MAPY (MAP & LOCATIONS) ---
    func uploadMap() async {
        guard
            let url = Bundle.main.url(
                forResource: "map_ytonga",
                withExtension: "json"
            )
        else {
            print("❌ Soubor map_ytonga.json nebyl nalezen!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard
                let mapDict = try JSONSerialization.jsonObject(
                    with: data,
                    options: []
                ) as? [String: Any],
                let locationsArray = mapDict["locations"] as? [[String: Any]],
                let mapId = mapDict["id"] as? String
            else {
                print("❌ Chyba: map_ytonga.json má špatnou strukturu.")
                return
            }

            // 1. Uložíme hlavní dokument mapy
            let mapData: [String: Any] = [
                "name": mapDict["name"] ?? "",
                "imageName": mapDict["imageName"] ?? "",
                "width": mapDict["width"] ?? 4000,
                "height": mapDict["height"] ?? 4000,
            ]

            try await db.collection("game_maps").document(mapId).setData(
                mapData
            )
            print("✅ Mapa: Hlavní data nahrána.")

            // 2. Uložíme lokace jako podkolekci (v Batchi)
            let batch = db.batch()
            var locCount = 0

            for location in locationsArray {
                guard let name = location["name"] as? String else { continue }

                // ID lokace je přímo její název (např. "Western Woods")
                let locRef = db.collection("game_maps").document(mapId)
                    .collection("locations").document(name)
                batch.setData(location, forDocument: locRef)
                locCount += 1
            }

            try await batch.commit()
            print("✅ Mapa: Úspěšně nahráno \(locCount) lokací.")

        } catch {
            print("❌ Chyba Mapy: \(error.localizedDescription)")
        }
    }

    // --- 4. STARTER PACK ---
    func giveStarterGear(to userId: String) {
        let inventoryRef = db.collection("users").document(userId).collection(
            "inventory"
        )

        // Items ID (musí odpovídat snake_case z uploadItems)
        let starterItems = [
            ["itemId": "rusty_sword", "quantity": 1],
            ["itemId": "basic_helmet", "quantity": 1],
            ["itemId": "health_potion", "quantity": 3],
            ["itemId": "basic_ration", "quantity": 5],
        ]

        for item in starterItems {
            inventoryRef.addDocument(data: item)
        }

        let equippedData: [String: String] = [
            "Zbraň": "rusty_sword",
            "Hlava": "basic_helmet",
        ]

        db.collection("users").document(userId).updateData([
            "equippedIds": equippedData
        ]) { err in
            if let err = err {
                print("❌ Chyba při dávání výbavy: \(err)")
            } else {
                print("🎒 Starter pack doručen uživateli \(userId)!")
            }
        }
    }

    // --- POMOCNÉ FUNKCE ---
    private func generateSnakeCaseId(from name: String) -> String {
        return name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
    }
}
