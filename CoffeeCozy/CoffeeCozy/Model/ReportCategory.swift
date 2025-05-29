//
//  ReportCategory.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// ReportCategory.swift

import Foundation

enum ReportCategory: String, CaseIterable, Identifiable {
    case login         = "Login"
    case registration  = "Registration"
    case deletion      = "Deletion"
    case nameChange    = "Name Change"
    // přidej další kategorie podle potřeby

    var id: String { rawValue }
}
