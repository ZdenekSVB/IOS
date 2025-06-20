//
//  LoginRecord.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import Foundation

struct LoginRecord: Identifiable {
    var id = UUID()
    var date: Date
    var count: Int
}
