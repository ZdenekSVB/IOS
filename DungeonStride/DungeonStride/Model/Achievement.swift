//
//  Achievement.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 05.11.2025.
//

import Foundation
import FirebaseFirestore

struct Achievement: Codable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let iconName: String
    let xpReward: Int
    let isUnlocked: Bool
    let unlockedAt: Date?
    let requirement: String
    let category: AchievementCategory
    
    init(
        id: String? = nil,
        title: String,
        description: String,
        iconName: String,
        xpReward: Int,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil,
        requirement: String,
        category: AchievementCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.xpReward = xpReward
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.requirement = requirement
        self.category = category
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case running = "running"
    case steps = "steps"
    case distance = "distance"
    case calories = "calories"
    case social = "social"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .running: return "Running"
        case .steps: return "Steps"
        case .distance: return "Distance"
        case .calories: return "Calories"
        case .social: return "Social"
        case .special: return "Special"
        }
    }
}

extension Achievement {
    func toFirestore() -> [String: Any] {
        return [
            "title": title,
            "description": description,
            "iconName": iconName,
            "xpReward": xpReward,
            "isUnlocked": isUnlocked,
            "unlockedAt": unlockedAt != nil ? Timestamp(date: unlockedAt!) : NSNull(),
            "requirement": requirement,
            "category": category.rawValue
        ]
    }
    
    static func fromFirestore(_ data: [String: Any]) -> Achievement? {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let iconName = data["iconName"] as? String,
              let xpReward = data["xpReward"] as? Int,
              let requirement = data["requirement"] as? String,
              let categoryRaw = data["category"] as? String,
              let category = AchievementCategory(rawValue: categoryRaw) else {
            return nil
        }
        
        let isUnlocked = data["isUnlocked"] as? Bool ?? false
        let unlockedAt = (data["unlockedAt"] as? Timestamp)?.dateValue()
        
        return Achievement(
            title: title,
            description: description,
            iconName: iconName,
            xpReward: xpReward,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt,
            requirement: requirement,
            category: category
        )
    }
}
