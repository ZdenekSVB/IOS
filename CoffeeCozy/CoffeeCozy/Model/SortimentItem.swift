//
// SortimentItem.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//
import Foundation
import FirebaseFirestore

struct SortimentItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var desc: String
    var image: String
    var price: Double
    var numOfOrders: Int
    var category: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case desc = "description"
        case image
        case price
        case numOfOrders
        case category
    }
}
