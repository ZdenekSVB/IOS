//
// User.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var firstname: String
    var lastname: String
    var phoneNumber: String
    var email: String
    var imageUrl: String?
    var role: String
    var createdAt: Date?
    var updatedAt: Date?

    var rewardPoints: Int?
}

struct UserStat: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
