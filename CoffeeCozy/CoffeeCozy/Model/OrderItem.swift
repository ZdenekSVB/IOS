//
//  OrderItem.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import Foundation
import FirebaseFirestore

struct OrderItemA: Identifiable{
    
    let id = UUID()
    let items: [OrderItemProduct]
    let status: String
    let totalPrice: Double
    let createdAt: Date
    
}


struct OrderItemProduct: Identifiable{
    let id = UUID()
    var name: String
    var price: Double
    var quantity: Int
    
}
