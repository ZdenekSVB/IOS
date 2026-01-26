//
//  DungeonContent.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import Foundation

struct DungeonStage: Identifiable {
    let id = UUID()
    let enemyId: String
    let stageIndex: Int
}

class DungeonContent {
    static func getEnemies(for locationName: String) -> [String] {
        switch locationName {
        case "Temné Bažiny":
            return ["green_slime", "giant_rat", "goblin_scout"]
            
        case "Staré Hory":
            return ["goblin_scout", "skeleton_warrior", "orc_berserker"]
            
        case "Křišťálová Jeskyně":
            return ["stone_golem", "dark_necromancer", "infernal_demon"]
            
        case "Pevnost Bouří":
             return ["skeleton_warrior", "orc_berserker", "ancient_red_dragon"]
            
        default:
            return ["green_slime", "giant_rat", "forest_wolf"]
        }
    }
}
