//
//  OrderRecord.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// OrderRecord.swift
// CoffeeCozy

import Foundation

struct OrderRecord: Identifiable {
    let id: UUID
    let userName: String
    let date: Date
    let total: Double
}
