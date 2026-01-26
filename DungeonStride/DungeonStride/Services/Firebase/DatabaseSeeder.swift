//
//  DatabaseSeeder.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 17.12.2025.
//

import FirebaseFirestore
import SwiftUI

class DatabaseSeeder {

    func uploadItemsToFirestore() {
        guard let url = Bundle.main.url(forResource: "items", withExtension: "json") else {
            print("❌ Soubor items.json nebyl nalezen v Bundle!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                print("❌ Chyba: JSON není pole objektů.")
                return
            }

            let db = Firestore.firestore()
            print("🚀 Začínám nahrávat \(jsonArray.count) itemů (RAW mód)...")

            // Změna na 'var' je nyní oprávněná, protože dictionary mutujeme
            for var itemDict in jsonArray {
                guard let name = itemDict["name"] as? String else { continue }

                let docId = name.lowercased()
                    .replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "'", with: "")

                // OPRAVA RARITY (aby se proměnná itemDict využila)
                if itemDict["rarity"] is NSNull || itemDict["rarity"] == nil {
                    itemDict["rarity"] = "Common"
                }
                
                // OPRAVA CENY
                if var stats = itemDict["baseStats"] as? [String: Any] {
                    if stats["sellPrice"] == nil || stats["sellPrice"] is NSNull {
                        stats["sellPrice"] = 10
                        itemDict["baseStats"] = stats
                    }
                }

                db.collection("items").document(docId).setData(itemDict) { error in
                    if let error = error {
                        print("❌ chyba u itemu \(name): \(error.localizedDescription)")
                    } else {
                        print("✅ Item nahrán: \(name)")
                    }
                }
            }

        } catch {
            print("❌ CHYBA PŘI ZPRACOVÁNÍ JSONu:")
            print(error)
        }
    }

    func giveStarterGear(to userId: String) {
        let db = Firestore.firestore()
        let inventoryRef = db.collection("users").document(userId).collection("inventory")

        let starterItems = [
            ["itemId": "knights_sword", "quantity": 1],
            ["itemId": "basic_helmet", "quantity": 1],
            ["itemId": "health_potion", "quantity": 3],
        ]

        for item in starterItems {
            inventoryRef.addDocument(data: item)
        }

        let equippedData: [String: String] = [
            "Zbraň": "knights_sword"
        ]

        db.collection("users").document(userId).updateData([
            "equippedIds": equippedData
        ]) { err in
            if let err = err {
                print("Chyba: \(err)")
            } else {
                print("Starter pack doručen!")
            }
        }
    }

    func uploadQuestsToFirestore() {
        guard let url = Bundle.main.url(forResource: "quests", withExtension: "json") else {
            print("❌ Soubor quests.json nebyl nalezen v Bundle!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                print("❌ Chyba: JSON není pole objektů.")
                return
            }

            let db = Firestore.firestore()
            print("🚀 Začínám nahrávat \(jsonArray.count) questů...")

            for var questDict in jsonArray {
                guard let title = questDict["title"] as? String else { continue }

                let docId = title.lowercased()
                    .replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "'", with: "")

                questDict["id"] = docId

                db.collection("quests").document(docId).setData(questDict) { error in
                    if let error = error {
                        print("❌ chyba u questu \(title): \(error.localizedDescription)")
                    } else {
                        print("✅ Quest nahrán: \(title)")
                    }
                }
            }

        } catch {
            print("❌ CHYBA PŘI ZPRACOVÁNÍ JSONu:")
            print(error)
        }
    }

    func uploadEnemiesToFirestore() {
        guard let url = Bundle.main.url(forResource: "enemies", withExtension: "json") else {
            print("❌ Soubor enemies.json nebyl nalezen v Bundle!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                print("❌ Chyba: JSON enemies není pole objektů.")
                return
            }

            let db = Firestore.firestore()
            print("🚀 Začínám nahrávat \(jsonArray.count) nepřátel...")

            // Změna na 'let', protože enemyDict nemutujeme (pokud ho neopravujeme)
            // Pokud bys chtěl opravovat data, změň na 'var' a přidej logiku.
            for enemyDict in jsonArray {
                guard let name = enemyDict["name"] as? String else { continue }

                let docId = name.lowercased()
                    .replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "'", with: "")

                db.collection("enemies").document(docId).setData(enemyDict) { error in
                    if let error = error {
                        print("❌ chyba u nepřítele \(name): \(error.localizedDescription)")
                    } else {
                        print("✅ Nepřítel nahrán: \(name)")
                    }
                }
            }

        } catch {
            print("❌ CHYBA PŘI ZPRACOVÁNÍ JSONu enemies:")
            print(error)
        }
    }
}
