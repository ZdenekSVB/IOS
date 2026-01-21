//
//  Quest.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import Foundation
import FirebaseFirestore

enum QuestRequirement: Codable {
    case steps(Int)
    case distance(Int)
    case calories(Int)
    case runs(Int)
    case dailyLogin(Int)
    
    var displayText: String {
        switch self {
        case .steps(let steps): return "\(steps) steps"
        case .distance(let meters): return meters >= 1000 ? String(format: "%.1f km", Double(meters) / 1000.0) : "\(meters) m"
        case .calories(let calories): return "\(calories) cal"
        case .runs(let runs): return "\(runs) runs"
        case .dailyLogin(let days): return "\(days) consecutive days"
        }
    }
    
    var totalRequired: Int {
        switch self {
        case .steps(let val): return val
        case .distance(let val): return val
        case .calories(let val): return val
        case .runs(let val): return val
        case .dailyLogin(let val): return val
        }
    }
}

struct Quest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    
    // Odměny
    let xpReward: Int
    let coinsReward: Int
    
    let requirement: QuestRequirement
    let totalRequired: Int
    
    // Pro správu denních resetů
    let startedAt: Date
    
    var progress: Int
    var isCompleted: Bool
    var completedAt: Date?
    
    init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        xpReward: Int,
        coinsReward: Int,
        requirement: QuestRequirement,
        progress: Int = 0,
        startedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.xpReward = xpReward
        self.coinsReward = coinsReward
        self.requirement = requirement
        self.progress = progress
        self.totalRequired = requirement.totalRequired
        self.startedAt = startedAt ?? Date()
        self.isCompleted = progress >= self.totalRequired
    }
    
    var progressPercentage: Double {
        guard totalRequired > 0 else { return 0 }
        return Double(progress) / Double(totalRequired)
    }
    
    mutating func updateProgress(_ newProgress: Int) {
        progress = min(newProgress, totalRequired)
        isCompleted = progress >= totalRequired
        if isCompleted && completedAt == nil {
            completedAt = Date()
        }
    }
}

extension Quest {
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "iconName": iconName,
            "xpReward": xpReward,
            "coinsReward": coinsReward,
            "requirement": requirementToString(requirement),
            "progress": progress,
            "totalRequired": totalRequired,
            "isCompleted": isCompleted,
            "startedAt": Timestamp(date: startedAt)
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
        case .steps(let v): return "steps:\(v)"
        case .distance(let v): return "distance:\(v)"
        case .calories(let v): return "calories:\(v)"
        case .runs(let v): return "runs:\(v)"
        case .dailyLogin(let v): return "dailyLogin:\(v)"
        }
    }
    
    static func fromFirestore(_ data: [String: Any]) -> Quest? {
        // 1. Získání POVINNÝCH polí (bez coinsReward)
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let iconName = data["iconName"] as? String,
              let xpReward = data["xpReward"] as? Int,
              let coinsReward = data["coinsReward"] as? Int,
              let requirementString = data["requirement"] as? String
        else {
            return nil
        }
        
        let progress = data["progress"] as? Int ?? 0
        let isCompleted = data["isCompleted"] as? Bool ?? false
        
        let requirement = parseRequirement(from: requirementString)
        
        var startedAt = Date()
        if let ts = data["startedAt"] as? Timestamp {
            startedAt = ts.dateValue()
        }
        
        var quest = Quest(
            id: id,
            title: title,
            description: description,
            iconName: iconName,
            xpReward: xpReward,
            coinsReward: coinsReward, // Zde použijeme načtenou hodnotu
            requirement: requirement,
            progress: progress,
            startedAt: startedAt
        )
        
        quest.isCompleted = isCompleted
        
        if let ts = data["completedAt"] as? Timestamp {
            quest.completedAt = ts.dateValue()
        }
        
        return quest
    }
    
    private static func parseRequirement(from string: String) -> QuestRequirement {
        let components = string.split(separator: ":")
        guard components.count == 2, let value = Int(components[1]) else { return .steps(0) }
        
        switch components[0] {
        case "steps": return .steps(value)
        case "distance": return .distance(value)
        case "calories": return .calories(value)
        case "runs": return .runs(value)
        case "dailyLogin": return .dailyLogin(value)
        default: return .steps(0)
        }
    }
}
