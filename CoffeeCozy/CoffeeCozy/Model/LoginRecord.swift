//
//  LoginRecord.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

// LoginRecord.swift

import Foundation

struct LoginRecord: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
