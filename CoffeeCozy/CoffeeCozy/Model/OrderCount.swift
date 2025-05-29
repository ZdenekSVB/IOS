//
//  OrderCount.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// OrderCount.swift
// CoffeeCozy

import Foundation

struct OrderCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
