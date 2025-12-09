//
//  Item.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct AItem: Codable, Identifiable {
    @DocumentID var id: String?
    
    let name: String
    let description: String
    let iconName: String
    let itemType: String        // "Weapon", "Armor", "Spell", "Potion", "Consumable"
    
    // Nové pole pro Rarity (uloženo jako String v Firestore)
    let rarity: Rarity
    
    // Základní staty (bez aplikovaného multiplikátoru rarity)
    let baseStats: ItemStats
    
    // Nové pole pro definování předpokladů (zatím prázdné)
    let prerequisite: String? // Např. "Level 10", "Adept ve spellcastingu"
    
    
    // Cena se skaluje podle rarity
    var finalSellPrice: Int? {
        guard let basePrice = baseStats.sellPrice else { return nil }
        return Int(Double(basePrice) * rarity.multiplier)
    }
    
    // Útok se skaluje podle rarity
    var finalAttack: Int? {
        guard let baseAttack = baseStats.attack else { return nil }
        return Int(Double(baseAttack) * rarity.multiplier)
    }
    
    // Obrana se skaluje podle rarity
    var finalDefense: Int? {
        guard let baseDefense = baseStats.defense else { return nil }
        return Int(Double(baseDefense) * rarity.multiplier)
    }
    
    // --- Pomocná struktura pro Item staty ---
    struct ItemStats: Codable {
        let attack: Int?     // Útočná síla (pro zbraně a kouzla)
        let defense: Int?    // Obrana (pro brnění)
        let healthBonus: Int? // Bonus k životu (pro brnění, lektvary)
        let sellPrice: Int?   // Základní prodejní cena
    }
}

enum Rarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case artifact = "Artifact"
    
    // Zde definujeme skalování statů a barevné schéma
    var multiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.0
        case .epic: return 2.5
        case .legendary: return 4.0
        case .artifact: return 6.0
        }
    }
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        case .artifact: return .red
        }
    }
}
