//
//  Order.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct OrderItem: Codable, Identifiable {
    var id: String { itemId }
    let itemId: String
    let name: String
    let price: Double
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case itemId, name, price, quantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        itemId = try container.decode(String.self, forKey: .itemId)
        name = try container.decode(String.self, forKey: .name)

        if let priceDouble = try? container.decode(Double.self, forKey: .price) {
            price = priceDouble
        } else if let priceString = try? container.decode(String.self, forKey: .price),
                  let priceDouble = Double(priceString) {
            price = priceDouble
        } else {
            throw DecodingError.dataCorruptedError(forKey: .price,
                                                   in: container,
                                                   debugDescription: "Price is not a valid Double or convertible String")
        }

        if let quantityInt = try? container.decode(Int.self, forKey: .quantity) {
            quantity = quantityInt
        } else if let quantityString = try? container.decode(String.self, forKey: .quantity),
                  let quantityInt = Int(quantityString) {
            quantity = quantityInt
        } else {
            throw DecodingError.dataCorruptedError(forKey: .quantity,
                                                   in: container,
                                                   debugDescription: "Quantity is not a valid Int or convertible String")
        }
    }
}


struct OrderRecord: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let createdAt: Date
    let finishedAt: Date
    let status: String
    let totalPrice: Double
    let items: [OrderItem]
    
    var userName: String = "Unknown User"

    enum CodingKeys: CodingKey {
        case id, userId, createdAt, finishedAt, status, totalPrice, items
    }
}

struct OrderCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

enum OrderStatus: String {
    case pending = "pending"
    case preparing = "preparing"
    case finished = "finished"
    case cancelled = "cancelled"
    case unknown = "unknown"

    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .preparing:
            return .yellow
        case .finished:
            return .green
        case .cancelled:
            return .red
        case .unknown:
            return .gray
        }
    }
}
