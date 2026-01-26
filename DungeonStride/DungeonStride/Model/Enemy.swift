//
//  Enemy.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import Foundation
import FirebaseFirestore

struct Enemy: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let description: String
    let enemyType: String
    let rarity: String
    let iconName: String
    
    var combatStats: CombatStats
    
    let rewards: LootRewards
    
    var currentHP: Int = 0
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        enemyType = try container.decode(String.self, forKey: .enemyType)
        rarity = try container.decode(String.self, forKey: .rarity)
        iconName = try container.decode(String.self, forKey: .iconName)
        combatStats = try container.decode(CombatStats.self, forKey: .combatStats)
        rewards = try container.decode(LootRewards.self, forKey: .rewards)
        
        currentHP = combatStats.hp
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, enemyType, rarity, iconName, combatStats, rewards
    }
}

struct CombatStats: Codable {
    let hp: Int
    let attack: Int
    let defense: Int
}

struct LootRewards: Codable {
    let xp: Int
    let coins: Int
}
