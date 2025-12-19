//
//  EquipSlot.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 19.12.2025.
//
import SwiftUI
import FirebaseFirestore

enum EquipSlot: String, CaseIterable, Identifiable {
    case mainHand = "Weapon"
    case offHand = "Shield"
    case head = "Head"
    case chest = "Chest"
    case hands = "Hands"
    case legs = "Legs"
    case feet = "Feet"
    
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
        default: return nil
        }
    }
}

struct InventoryItem: Identifiable, Equatable {
    let id: String
    let item: AItem
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

struct UserInventorySlot: Codable, Identifiable {
    @DocumentID var id: String?
    let itemId: String
    var quantity: Int
    
    enum CodingKeys: String, CodingKey {
            case id
            case itemId = "item_id" 
            case quantity
        }
}
