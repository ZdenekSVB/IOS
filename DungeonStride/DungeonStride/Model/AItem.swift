//
//  Item.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import FirebaseFirestore
import Foundation
import SwiftUI

// MARK: - Master Item Definition
struct AItem: Codable, Identifiable {
    @DocumentID var id: String?

    let name: String
    let description: String
    let iconName: String
    let itemType: String
    let rarity: Rarity?
    let baseStats: ItemStats
    let costs: CostStats

    // Helper: Rozlišení, zda jde o SF Symbol (systémová ikona) nebo Asset
    var isSystemIcon: Bool {
        return iconName.contains(".")
    }

    private var effectiveMultiplier: Double {
        return rarity?.multiplier ?? 1
    }

    var finalSellPrice: Int? {
        guard let basePrice = baseStats.sellPrice else { return nil }
        return Int(Double(basePrice) * effectiveMultiplier)
    }

    var finalPhysicalDamage: Int? {
        guard let base = baseStats.physicalDamage else { return nil }
        return Int(Double(base) * effectiveMultiplier)
    }

    var finalMagicDamage: Int? {
        guard let base = baseStats.magicDamage else { return nil }
        return Int(Double(base) * effectiveMultiplier)
    }

    var finalPhysicalDefense: Int? {
        guard let base = baseStats.physicalDefense else { return nil }
        return Int(Double(base) * effectiveMultiplier)
    }

    var finalMagicDefense: Int? {
        guard let base = baseStats.magicDefense else { return nil }
        return Int(Double(base) * effectiveMultiplier)
    }

    var finalHealthBonus: Int? {
        guard let base = baseStats.healthBonus else { return nil }
        return Int(Double(base) * effectiveMultiplier)
    }

    var finalManaBonus: Int? {
        guard let base = baseStats.manaBonus else { return nil }
        return Int(Double(base) * effectiveMultiplier)
    }

    struct ItemStats: Codable {
        let physicalDamage: Int?
        let magicDamage: Int?
        let physicalDefense: Int?
        let magicDefense: Int?
        let healthBonus: Int?
        let manaBonus: Int?
        let sellPrice: Int?
    }

    struct CostStats: Codable {
        let energyCost: Int?
        let manaCost: Int?
    }
}

enum Rarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case artifact = "Artifact"

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

// MARK: - Inventory Models (JEDINÁ DEFINICE)

// 1. Co je uloženo ve Firestore v kolekci "inventory"
struct UserInventorySlot: Codable, Identifiable {
    @DocumentID var id: String?
    let itemId: String
    var quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemId
        case quantity
    }
}

// 2. Co používáme v UI
struct InventoryItem: Identifiable, Equatable {
    let id: String              // ID dokumentu z batohu
    let item: AItem             // Plná data
    var quantity: Int
    
    var rarityRank: Int {
        switch item.rarity {
        case .artifact: return 6
        case .legendary: return 5
        case .epic: return 4
        case .rare: return 3
        case .uncommon: return 2
        case .common: return 1
        case .none: return 0
        }
    }
    
    static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.id == rhs.id && lhs.quantity == rhs.quantity
    }
}
enum EquipSlot: String, CaseIterable, Identifiable {
    case mainHand = "Weapon"
    case offHand = "Shield"
    case head = "Head"
    case chest = "Chest"
    case hands = "Hands"
    case legs = "Legs"
    case feet = "Feet"
    
    // --- NOVÉ SLOTY PRO KOUZLA ---
    case spell1 = "Spell 1"
    case spell2 = "Spell 2"
    case spell3 = "Spell 3"
    
    var id: String { self.rawValue }
    
    var placeholderIcon: String {
        switch self {
        case .mainHand: return "sword"
        case .offHand: return "shield"
        case .head: return "hat.cap.fill"
        case .chest: return "tshirt.fill"
        case .hands: return "hand.raised.fill"
        case .legs: return "figure.walk"
        case .feet: return "shoe.fill"
        case .spell1, .spell2, .spell3: return "sparkles" // Ikona pro kouzla
        }
    }
}

extension AItem {
    var computedSlot: EquipSlot? {
        switch itemType {
        case "Weapon":      return .mainHand
        case "Shield":      return .offHand
        case "Helmet":      return .head
        case "Chestplate":  return .chest
        case "Gloves":      return .hands
        case "Leggings":    return .legs
        case "Boots":       return .feet
        // Spell vrací spell1 jako default, logika viewModelu to pak může přehodit do volného slotu
        case "Spell":       return .spell1
        default: return nil
        }
    }
}
