import Foundation
import FirebaseFirestore

struct OrderRecord: Identifiable, Codable {
    var id: String
    var userName: String?      // jméno uživatele, může být nil
    var userId: String
    var createdAt: Date
    var finishedAt: Date
    var total: Double          // původní total, ale nebude se používat na výpočet
    var items: [OrderItem]
    
    var displayUserName: String {
        userName?.isEmpty == false ? userName! : "Unknown User"
    }
    
    // Nová computed property: spočítaný total z položek
    var calculatedTotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case userId
        case createdAt
        case finishedAt
        case total
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        }
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .finishedAt) {
            finishedAt = timestamp.dateValue()
        } else {
            finishedAt = try container.decodeIfPresent(Date.self, forKey: .finishedAt) ?? Date()
        }
        
        if let totalDouble = try? container.decode(Double.self, forKey: .total) {
            total = totalDouble
        } else if let totalString = try? container.decode(String.self, forKey: .total),
                  let totalVal = Double(totalString) {
            total = totalVal
        } else {
            total = 0.0
        }
        
        items = (try? container.decode([OrderItem].self, forKey: .items)) ?? []
    }
}

struct OrderItem: Identifiable, Codable {
    var id: String { itemId }
    var itemId: String
    var name: String
    var price: Double
    var quantity: Int
    var totalPrice: Double
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case itemId, name, price, quantity, totalPrice, status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        itemId = try container.decodeIfPresent(String.self, forKey: .itemId) ?? UUID().uuidString
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        
        if let p = try? container.decode(Double.self, forKey: .price) {
            price = p
        } else if let pStr = try? container.decode(String.self, forKey: .price), let p = Double(pStr) {
            price = p
        } else {
            price = 0
        }
        
        if let q = try? container.decode(Int.self, forKey: .quantity) {
            quantity = q
        } else if let qStr = try? container.decode(String.self, forKey: .quantity), let q = Int(qStr) {
            quantity = q
        } else {
            quantity = 1
        }
        
        if let tp = try? container.decode(Double.self, forKey: .totalPrice) {
            totalPrice = tp
        } else {
            totalPrice = price * Double(quantity)
        }
        
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "pending"
    }
}

struct OrderCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
