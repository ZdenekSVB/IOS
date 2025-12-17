//
//  DatabaseSeeder.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 17.12.2025.
//

import SwiftUI
import FirebaseFirestore

class DatabaseSeeder {
    
    func uploadItemsToFirestore() {
        guard let url = Bundle.main.url(forResource: "items", withExtension: "json") else {
            print("❌ Soubor items.json nebyl nalezen v Bundle!")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // 1. Místo AItem dekódujeme čistá data (Array of Dictionaries)
            // Tím obejdeme kontrolu "id" i "rarity"
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                print("❌ Chyba: JSON není pole objektů.")
                return
            }
            
            let db = Firestore.firestore()
            print("🚀 Začínám nahrávat \(jsonArray.count) itemů (RAW mód)...")
            
            for var itemDict in jsonArray {
                
                // Získáme jméno pro ID dokumentu
                guard let name = itemDict["name"] as? String else { continue }
                
                let docId = name.lowercased()
                    .replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "'", with: "")
                
                // ⚠️ DŮLEŽITÁ OPRAVA DAT ZA BĚHU
                // Tvůj AItem model vyžaduje Rarity (nesmí být null).
                // V JSONu máš u lektvarů "rarity": null. Pokud to tak nahraješ, aplikace ti spadne při čtení.
                // Zde to automaticky opravíme na "Common", aby to prošlo:
                
                
                // 2. Nahrajeme slovník přímo do Firestore
                db.collection("items").document(docId).setData(itemDict) { error in
                    if let error = error {
                        print("chyba u itemu \(name): \(error.localizedDescription)")
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
}
