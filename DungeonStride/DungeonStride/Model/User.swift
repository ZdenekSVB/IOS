//
//  User.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore

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

// MARK: — Hlavní User model

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    
    
    let email: String
    let username: String
    var selectedAvatar: String
    
    
    var stats: PlayerStats
    var coins: Int
    var gems: Int
    var premiumMember: Bool
    var totalXP: Int
    
    
    var activityStats: ActivityStats
    var dailyActivity: DailyActivity
    
    
    var settings: UserSettings
    
    
    var myAchievements: [Achievement]
    var currentQuests: [Quest]
    var completedQuests: [Quest]
    
    
    let createdAt: Date
    var updatedAt: Date
    var lastActiveAt: Date
    
    
    var level: Int {
        return (totalXP / 100) + 1
    }
    var xpToNextLevel: Int {
        return (level * 100) - totalXP
    }
    var levelProgress: Double {
        let currentLevelXP = totalXP % 100
        return Double(currentLevelXP) / 100.0
    }
    
    var uid: String {
        return id ?? ""
    }
    
    
    init(
        id: String? = nil,
        email: String,
        username: String,
        selectedAvatar: String = "default",
        stats: PlayerStats = PlayerStats(hp: 100, maxHP: 100, physicalDamage: 10, magicDamage: 5, defense: 5, speed: 10, evasion: 0.05),
        coins: Int = 0,
        gems: Int = 0,
        premiumMember: Bool = false,
        totalXP: Int = 0,
        activityStats: ActivityStats = ActivityStats(totalRuns: 0, totalDistance: 0, totalCaloriesBurned: 0, totalSteps: 0),
        dailyActivity: DailyActivity = DailyActivity(dailySteps: 0, dailyDistance: 0, dailyCaloriesBurned: 0),
        settings: UserSettings = UserSettings(isDarkMode: false, notificationsEnabled: true, soundEffectsEnabled: true, units: .metric),
        myAchievements: [Achievement] = [],
        currentQuests: [Quest] = [],
        completedQuests: [Quest] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.selectedAvatar = selectedAvatar
        
        self.stats = stats
        self.coins = coins
        self.gems = gems
        self.premiumMember = premiumMember
        self.totalXP = totalXP
        
        self.activityStats = activityStats
        self.dailyActivity = dailyActivity
        
        self.settings = settings
        
        self.myAchievements = myAchievements
        self.currentQuests = currentQuests
        self.completedQuests = completedQuests
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastActiveAt = lastActiveAt
    }
    
    // MARK: — Helper metody
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        updatedAt = Date()
    }
    mutating func addCoins(_ amount: Int) {
        coins += amount
        updatedAt = Date()
    }
    mutating func addGems(_ amount: Int) {
        gems += amount
        updatedAt = Date()
    }
    mutating func updateDailyProgress(steps: Int, distance: Int, calories: Int) {
        dailyActivity.dailySteps = steps
        dailyActivity.dailyDistance = distance
        dailyActivity.dailyCaloriesBurned = calories
        
        activityStats.totalSteps += steps
        activityStats.totalDistance += distance
        activityStats.totalCaloriesBurned += calories
        
        updatedAt = Date()
    }
    mutating func completeQuest(_ quest: Quest) {
        if let index = currentQuests.firstIndex(where: { $0.id == quest.id }) {
            currentQuests.remove(at: index)
            var completed = quest
            completed.completedAt = Date()
            completedQuests.append(completed)
            
            addXP(quest.xpReward)
            addCoins(quest.xpReward / 10)
            
            updatedAt = Date()
        }
    }
}
// MARK: - Firestore Helpers
extension User {
    func toFirestore() -> [String: Any] {
        return [
            "email": email,
            "username": username,
            "selectedAvatar": selectedAvatar,
            
            // Stats
            "stats": [
                "hp": stats.hp,
                "maxHP": stats.maxHP,
                "physicalDamage": stats.physicalDamage,
                "magicDamage": stats.magicDamage,
                "defense": stats.defense,
                "speed": stats.speed,
                "evasion": stats.evasion
            ],
            
            // Economy / progression
            "coins": coins,
            "gems": gems,
            "premiumMember": premiumMember,
            "totalXP": totalXP,
            
            // Activity stats
            "activityStats": [
                "totalRuns": activityStats.totalRuns,
                "totalDistance": activityStats.totalDistance,
                "totalCaloriesBurned": activityStats.totalCaloriesBurned,
                "totalSteps": activityStats.totalSteps
            ],
            
            // Daily activity
            "dailyActivity": [
                "dailySteps": dailyActivity.dailySteps,
                "dailyDistance": dailyActivity.dailyDistance,
                "dailyCaloriesBurned": dailyActivity.dailyCaloriesBurned
            ],
            
            // Settings
            "settings": [
                "isDarkMode": settings.isDarkMode,
                "notificationsEnabled": settings.notificationsEnabled,
                "soundEffectsEnabled": settings.soundEffectsEnabled,
                "units": settings.units.rawValue
            ],
            
            // Achievements & Quests
            "myAchievements": myAchievements.map { $0.toFirestore() },
            "currentQuests": currentQuests.map { $0.toFirestore() },
            "completedQuests": completedQuests.map { $0.toFirestore() },
            
            // Timestamps
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "lastActiveAt": Timestamp(date: lastActiveAt)
        ]
    }

    static func fromFirestore(documentId: String, data: [String: Any]) -> User? {
        guard let email = data["email"] as? String,
              let username = data["username"] as? String else {
            return nil
        }
        
        let selectedAvatar = data["selectedAvatar"] as? String ?? "default"

        // Parse stats
        let statsDict = data["stats"] as? [String: Any] ?? [:]
        let stats = PlayerStats(
            hp: statsDict["hp"] as? Int ?? 100,
            maxHP: statsDict["maxHP"] as? Int ?? 100,
            physicalDamage: statsDict["physicalDamage"] as? Int ?? 10,
            magicDamage: statsDict["magicDamage"] as? Int ?? 5,
            defense: statsDict["defense"] as? Int ?? 5,
            speed: statsDict["speed"] as? Int ?? 10,
            evasion: statsDict["evasion"] as? Double ?? 0.0
        )

        // Parse economy / progression
        let coins = data["coins"] as? Int ?? 0
        let gems = data["gems"] as? Int ?? 0
        let premiumMember = data["premiumMember"] as? Bool ?? false
        let totalXP = data["totalXP"] as? Int ?? 0

        // Parse activity stats
        let actStatsDict = data["activityStats"] as? [String: Any] ?? [:]
        let activityStats = ActivityStats(
            totalRuns: actStatsDict["totalRuns"] as? Int ?? 0,
            totalDistance: actStatsDict["totalDistance"] as? Int ?? 0,
            totalCaloriesBurned: actStatsDict["totalCaloriesBurned"] as? Int ?? 0,
            totalSteps: actStatsDict["totalSteps"] as? Int ?? 0
        )

        // Parse daily activity
        let dailyActDict = data["dailyActivity"] as? [String: Any] ?? [:]
        let dailyActivity = DailyActivity(
            dailySteps: dailyActDict["dailySteps"] as? Int ?? 0,
            dailyDistance: dailyActDict["dailyDistance"] as? Int ?? 0,
            dailyCaloriesBurned: dailyActDict["dailyCaloriesBurned"] as? Int ?? 0
        )

        // Parse settings
        let settingsDict = data["settings"] as? [String: Any] ?? [:]
        let unitsRaw = settingsDict["units"] as? String ?? DistanceUnit.metric.rawValue
        let settings = UserSettings(
            isDarkMode: settingsDict["isDarkMode"] as? Bool ?? false,
            notificationsEnabled: settingsDict["notificationsEnabled"] as? Bool ?? true,
            soundEffectsEnabled: settingsDict["soundEffectsEnabled"] as? Bool ?? true,
            units: DistanceUnit(rawValue: unitsRaw) ?? .metric
        )

        // Parse achievements & quests
        let achData = data["myAchievements"] as? [[String: Any]] ?? []
        let myAchievements = achData.compactMap { Achievement.fromFirestore($0) }

        let currQuestData = data["currentQuests"] as? [[String: Any]] ?? []
        let currentQuests = currQuestData.compactMap { Quest.fromFirestore($0) }

        let compQuestData = data["completedQuests"] as? [[String: Any]] ?? []
        let completedQuests = compQuestData.compactMap { Quest.fromFirestore($0) }

        // Parse timestamps
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        let lastActiveAt = (data["lastActiveAt"] as? Timestamp)?.dateValue() ?? Date()

        return User(
            id: documentId,
            email: email,
            username: username,
            selectedAvatar: selectedAvatar,
            stats: stats,
            coins: coins,
            gems: gems,
            premiumMember: premiumMember,
            totalXP: totalXP,
            activityStats: activityStats,
            dailyActivity: dailyActivity,
            settings: settings,
            myAchievements: myAchievements,
            currentQuests: currentQuests,
            completedQuests: completedQuests,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastActiveAt: lastActiveAt
        )
    }
}
