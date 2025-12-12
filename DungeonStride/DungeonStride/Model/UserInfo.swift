//
//  UserInfo.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
//
import Foundation

struct PlayerStats: Codable {
    var hp: Int
    var maxHP: Int
    var physicalDamage: Int
    var magicDamage: Int
    var defense: Int
    var speed: Int
    var evasion: Double
}

struct UserSettings: Codable {
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    var soundEffectsEnabled: Bool
    var units: DistanceUnit
}

struct DailyActivity: Codable {
    var dailySteps: Int
    var dailyDistance: Int
    var dailyCaloriesBurned: Int
}

struct ActivityStats: Codable {
    var totalRuns: Int
    var totalDistance: Int
    var totalCaloriesBurned: Int
    var totalSteps: Int
}

extension UserSettings {
    func toFirestore() -> [String: Any] {
        return [
            "isDarkMode": isDarkMode,
            "notificationsEnabled": notificationsEnabled,
            "soundEffectsEnabled": soundEffectsEnabled,
            "units": units.rawValue
        ]
    }
    
    static func fromFirestore(data: [String: Any]) -> UserSettings? {
        guard let isDarkMode = data["isDarkMode"] as? Bool,
              let notificationsEnabled = data["notificationsEnabled"] as? Bool,
              let soundEffectsEnabled = data["soundEffectsEnabled"] as? Bool,
              let unitsString = data["units"] as? String else {
            return nil
        }
        
        let units = DistanceUnit(rawValue: unitsString) ?? .metric
        
        return UserSettings(
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled,
            soundEffectsEnabled: soundEffectsEnabled,
            units: units
        )
    }
}

extension PlayerStats {
    func toFirestore() -> [String: Any] {
        return [
            "hp": hp,
            "maxHP": maxHP,
            "physicalDamage": physicalDamage,
            "magicDamage": magicDamage,
            "defense": defense,
            "speed": speed,
            "evasion": evasion
        ]
    }
}
