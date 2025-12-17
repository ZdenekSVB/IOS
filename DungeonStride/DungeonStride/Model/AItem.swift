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
    let itemType: String
    let rarity: Rarity?
    let baseStats: ItemStats
    let prerequisite: String?
    let costs: CostStats
    
    private var effectiveMultiplier: Double {
        return rarity?.multiplier ?? 1
        }
    
    var finalSellPrice: Int? {
            guard let basePrice = baseStats.sellPrice else { return nil }
            return Int(Double(basePrice) * effectiveMultiplier)
        }
    
    var finalAttack: Int? {
           guard let baseAttack = baseStats.attack else { return nil }
           return Int(Double(baseAttack) * effectiveMultiplier)
       }
    
    var finalDefense: Int? {
            guard let baseDefense = baseStats.defense else { return nil }
            return Int(Double(baseDefense) * effectiveMultiplier)
        }
    
    struct ItemStats: Codable {
        let attack: Int?
        let defense: Int?
        let healthBonus: Int?
        let sellPrice: Int?
    }
    
    struct CostStats: Codable {
           let practiceType: String?
           let requiredPractice: Int?
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
