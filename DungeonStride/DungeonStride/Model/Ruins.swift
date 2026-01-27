//
//  Ruins.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 27.01.2026.
//

import Foundation
import SwiftUI

enum RuinsDoorType: String, CaseIterable {
    case combat = "Nepřítel"
    case treasure = "Poklad"
    case item = "Předmět"
    case trap = "Past"
    case heal = "Studánka"
    case boss = "BOSS"
    
    var icon: String {
        switch self {
        case .combat: return "skull_icon"
        case .treasure: return "centsign.circle.fill"
        case .item: return "backpack.fill"
        case .trap: return "exclamationmark.triangle.fill"
        case .heal: return "heart.fill"
        case .boss: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .combat: return .red
        case .treasure: return .yellow
        case .item: return .purple
        case .trap: return .orange
        case .heal: return .green
        case .boss: return .black
        }
    }
}

struct RuinsDoor: Identifiable {
    let id = UUID()
    let type: RuinsDoorType
    var isRevealed: Bool = false
}
