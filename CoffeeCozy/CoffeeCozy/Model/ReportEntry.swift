//
//  ReportEntry.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// ReportEntry.swift

import Foundation

struct ReportEntry: Identifiable {
    let id = UUID()
    let category: ReportCategory
    let message: String
    let date: Date
}
