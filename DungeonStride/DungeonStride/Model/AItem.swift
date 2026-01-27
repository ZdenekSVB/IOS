//
//  Item.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct AItem: Codable, Identifiable {
    @DocumentID var id: String?

    let name: String
    let description: String
    let iconName: String
    let itemType: String
    let rarity: Rarity?
    let baseStats: ItemStats
    let costs: CostStats

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
