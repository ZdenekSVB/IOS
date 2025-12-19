//
//  ShopModels.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 19.12.2025.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct ShopSlot: Codable, Identifiable {
    var id: String = UUID().uuidString
    let itemId: String
    let price: Int
    var isPurchased: Bool
}

struct UserShopData: Codable {
    var lastResetDate: Date
    var slots: [ShopSlot]
    
    static let empty = UserShopData(
            lastResetDate: Date().addingTimeInterval(-90000),
            slots: []
        )
    
    func toFirestore() -> [String: Any] {
        [
            "lastResetDate": Timestamp(date: lastResetDate),
            "slots": slots.map { [
                "id": $0.id,
                "itemId": $0.itemId,
                "price": $0.price,
                "isPurchased": $0.isPurchased
            ] }
        ]
    }
    
    static func fromFirestore(_ data: [String: Any]) -> UserShopData {
            // I tady změníme fallback z distantPast na bezpečné datum
            let safePastDate = Date().addingTimeInterval(-90000)
            
            let date = (data["lastResetDate"] as? Timestamp)?.dateValue() ?? safePastDate
            let slotsData = data["slots"] as? [[String: Any]] ?? []
            
            let slots = slotsData.map { dict in
                ShopSlot(
                    id: dict["id"] as? String ?? UUID().uuidString,
                    itemId: dict["itemId"] as? String ?? "",
                    price: dict["price"] as? Int ?? 0,
                    isPurchased: dict["isPurchased"] as? Bool ?? false
                )
            }
            
            return UserShopData(lastResetDate: date, slots: slots)
        }
}
