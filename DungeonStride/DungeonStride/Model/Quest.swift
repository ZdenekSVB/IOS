//
//  Quest.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore

// MARK: - Quest Requirement Enum
enum QuestRequirement: Codable {
    case steps(Int)           // počet kroků
    case distance(Int)        // distance v METRECH
    case calories(Int)        // kalorie
    case runs(Int)           // počet běhů
    case dailyLogin(Int)     // dny v řadě
    
    var displayText: String {
        switch self {
        case .steps(let steps):
            return "\(steps) steps"
        case .distance(let meters):
            if meters >= 1000 {
                return String(format: "%.1f km", Double(meters) / 1000.0)
            } else {
                return "\(meters) m"
            }
        case .calories(let calories):
            return "\(calories) cal"
        case .runs(let runs):
            return "\(runs) runs"
        case .dailyLogin(let days):
            return "\(days) consecutive days"
        }
    }
    
    var totalRequired: Int {
        switch self {
        case .steps(let value): return value
        case .distance(let value): return value
        case .calories(let value): return value
        case .runs(let value): return value
        case .dailyLogin(let value): return value
        }
    }
}

// MARK: - Quest Model
struct Quest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let xpReward: Int
    let requirement: QuestRequirement
    let totalRequired: Int
    let startedAt: Date
    
    var progress: Int
    var isCompleted: Bool
    var completedAt: Date?
    var updatedAt: Date?
    
    init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        xpReward: Int,
        requirement: QuestRequirement,
        progress: Int = 0,
        startedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.xpReward = xpReward
        self.requirement = requirement
        self.progress = progress
        self.totalRequired = requirement.totalRequired
        self.startedAt = startedAt ?? Date()
        self.isCompleted = progress >= self.totalRequired
        self.updatedAt = Date()
    }
    
    var progressPercentage: Double {
        guard totalRequired > 0 else { return 0 }
        return Double(progress) / Double(totalRequired)
    }
    
    var requirementText: String {
        requirement.displayText
    }
    
    mutating func updateProgress(_ newProgress: Int) {
        progress = min(newProgress, totalRequired)
        isCompleted = progress >= totalRequired
        updatedAt = Date()
        if isCompleted && completedAt == nil {
            completedAt = Date()
        }
    }
    
    mutating func addProgress(_ amount: Int) {
        updateProgress(progress + amount)
    }
}

// MARK: - Firestore Helpers
extension Quest {
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "iconName": iconName,
            "xpReward": xpReward,
            "requirement": requirementToString(requirement),
            "progress": progress,
            "totalRequired": totalRequired,
            "isCompleted": isCompleted,
            "startedAt": Timestamp(date: startedAt),
            "updatedAt": Timestamp(date: updatedAt ?? Date())
        ]
        
        if let completedAt = completedAt {
            data["completedAt"] = Timestamp(date: completedAt)
        } else {
            data["completedAt"] = NSNull()
        }
        
        return data
    }
    
    private func requirementToString(_ requirement: QuestRequirement) -> String {
        switch requirement {
        case .steps(let value):
            return "steps:\(value)"
        case .distance(let value):
            return "distance:\(value)"
        case .calories(let value):
            return "calories:\(value)"
        case .runs(let value):
            return "runs:\(value)"
        case .dailyLogin(let value):
            return "dailyLogin:\(value)"
        }
    }
    
    static func fromFirestore(_ data: [String: Any]) -> Quest? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let iconName = data["iconName"] as? String,
              let xpReward = data["xpReward"] as? Int,
              let requirementString = data["requirement"] as? String,
              let progress = data["progress"] as? Int,
              let totalRequired = data["totalRequired"] as? Int else {
            return nil
        }
        
        let requirement = parseRequirement(from: requirementString)
        
        // Získat startedAt z dat
        var startedAt = Date()
        if let startedTimestamp = data["startedAt"] as? Timestamp {
            startedAt = startedTimestamp.dateValue()
        }
        
        // Vytvořit quest
        var quest = Quest(
            id: id,
            title: title,
            description: description,
            iconName: iconName,
            xpReward: xpReward,
            requirement: requirement,
            progress: progress,
            startedAt: startedAt
        )
        
        // Nastavit completedAt
        if let completedTimestamp = data["completedAt"] as? Timestamp {
            quest.completedAt = completedTimestamp.dateValue()
        }
        
        // Nastavit updatedAt
        if let updatedTimestamp = data["updatedAt"] as? Timestamp {
            quest.updatedAt = updatedTimestamp.dateValue()
        }
        
        return quest
    }
    
    private static func parseRequirement(from string: String) -> QuestRequirement {
        let components = string.split(separator: ":")
        guard components.count == 2,
              let value = Int(components[1]) else {
            return .steps(0)
        }
        
        switch components[0] {
        case "steps":
            return .steps(value)
        case "distance":
            return .distance(value)
        case "calories":
            return .calories(value)
        case "runs":
            return .runs(value)
        case "dailyLogin":
            return .dailyLogin(value)
        default:
            return .steps(0)
        }
    }
}
