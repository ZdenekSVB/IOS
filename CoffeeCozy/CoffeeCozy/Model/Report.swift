//
//  ReportCategory 2.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 17.06.2025.
//


import Foundation
import FirebaseFirestore

enum ReportCategory: String, CaseIterable, Identifiable, Codable {
    case login = "Login"
    case registration = "Registration"
    case deletion = "Deletion"
    case nameChange = "Name Change"

    var id: String { self.rawValue }
}

struct ReportEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var category: ReportCategory
    var message: String
    var date: Date
}
