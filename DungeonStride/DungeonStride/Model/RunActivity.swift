//
//  RunActivity.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore

struct RunActivity: Codable, Identifiable {
    @DocumentID var id: String?
    let type: String
    let distanceKm: Double
    let duration: TimeInterval
    let calories: Int
    let pace: Double
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case distanceKm = "distance_km"
        case duration
        case calories = "calories_kcal"
        case pace = "avg_pace_min_km"
        case timestamp
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
