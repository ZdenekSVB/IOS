//
//  User.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let uid: String
    let email: String
    let username: String
    
    // Avatar system
    var selectedAvatar: String
    
    // Progress
    var totalXP: Int
    
    // Activity Stats
    var totalRuns: Int
    var totalDistance: Int // v metrech
    var totalCaloriesBurned: Int
    var totalSteps: Int
    
    // Achievements
    var myAchievements: [Achievement]
    
    // Settings & Preferences
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    var soundEffectsEnabled: Bool
    var units: DistanceUnit
    
    // Daily Progress
    var dailySteps: Int
    var dailyDistance: Int // v metrech
    var dailyCaloriesBurned: Int
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    var lastActiveAt: Date
    
    // Social & Progression
    var currentQuests: [Quest]
    var completedQuests: [Quest]
    
    // Economy
    var coins: Int
    var gems: Int
    var premiumMember: Bool
    
    // MARK: - Computed Properties
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
    
    // MARK: - Initializers
    init(
        id: String? = nil,
        uid: String,
        email: String,
        username: String,
        selectedAvatar: String = "default",
        totalXP: Int = 0,
        totalRuns: Int = 0,
        totalDistance: Int = 0,
        totalCaloriesBurned: Int = 0,
        totalSteps: Int = 0,
        myAchievements: [Achievement] = [],
        isDarkMode: Bool = false,
        notificationsEnabled: Bool = true,
        soundEffectsEnabled: Bool = true,
        units: DistanceUnit = .metric,
        dailySteps: Int = 0,
        dailyDistance: Int = 0,
        dailyCaloriesBurned: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastActiveAt: Date = Date(),
        currentQuests: [Quest] = [],
        completedQuests: [Quest] = [],
        coins: Int = 0,
        gems: Int = 0,
        premiumMember: Bool = false
    ) {
        self.id = id
        self.uid = uid
        self.email = email
        self.username = username
        self.selectedAvatar = selectedAvatar
        self.totalXP = totalXP
        self.totalRuns = totalRuns
        self.totalDistance = totalDistance
        self.totalCaloriesBurned = totalCaloriesBurned
        self.totalSteps = totalSteps
        self.myAchievements = myAchievements
        self.isDarkMode = isDarkMode
        self.notificationsEnabled = notificationsEnabled
        self.soundEffectsEnabled = soundEffectsEnabled
        self.units = units
        self.dailySteps = dailySteps
        self.dailyDistance = dailyDistance
        self.dailyCaloriesBurned = dailyCaloriesBurned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastActiveAt = lastActiveAt
        self.currentQuests = currentQuests
        self.completedQuests = completedQuests
        self.coins = coins
        self.gems = gems
        self.premiumMember = premiumMember
    }
    
    // MARK: - Helper Methods
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
        dailySteps = steps
        dailyDistance = distance
        dailyCaloriesBurned = calories
        
        totalSteps += steps
        totalDistance += distance
        totalCaloriesBurned += calories
        
        updatedAt = Date()
    }
    
    mutating func completeQuest(_ quest: Quest) {
        if let index = currentQuests.firstIndex(where: { $0.id == quest.id }) {
            currentQuests.remove(at: index)
            var completedQuest = quest
            completedQuest.completedAt = Date()
            completedQuests.append(completedQuest)
            
            // Přidat odměny
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
            "uid": uid,
            "email": email,
            "username": username,
            "selectedAvatar": selectedAvatar,
            "totalXP": totalXP,
            "totalRuns": totalRuns,
            "totalDistance": totalDistance,
            "totalCaloriesBurned": totalCaloriesBurned,
            "totalSteps": totalSteps,
            "myAchievements": myAchievements.map { $0.toFirestore() },
            "isDarkMode": isDarkMode,
            "notificationsEnabled": notificationsEnabled,
            "soundEffectsEnabled": soundEffectsEnabled,
            "units": units.rawValue,
            "dailySteps": dailySteps,
            "dailyDistance": dailyDistance,
            "dailyCaloriesBurned": dailyCaloriesBurned,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "lastActiveAt": Timestamp(date: lastActiveAt),
            "currentQuests": currentQuests.map { $0.toFirestore() },
            "completedQuests": completedQuests.map { $0.toFirestore() },
            "coins": coins,
            "gems": gems,
            "premiumMember": premiumMember
        ]
    }
    
    static func fromFirestore(_ data: [String: Any]) -> User? {
        guard let uid = data["uid"] as? String,
              let email = data["email"] as? String,
              let username = data["username"] as? String else {
            return nil
        }
        
        // Parse basic data
        let selectedAvatar = data["selectedAvatar"] as? String ?? "default"
        let totalXP = data["totalXP"] as? Int ?? 0
        let totalRuns = data["totalRuns"] as? Int ?? 0
        let totalDistance = data["totalDistance"] as? Int ?? 0
        let totalCaloriesBurned = data["totalCaloriesBurned"] as? Int ?? 0
        let totalSteps = data["totalSteps"] as? Int ?? 0
        
        // Parse settings
        let isDarkMode = data["isDarkMode"] as? Bool ?? false
        let notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        let soundEffectsEnabled = data["soundEffectsEnabled"] as? Bool ?? true
        let unitsRaw = data["units"] as? String ?? "metric"
        let units = DistanceUnit(rawValue: unitsRaw) ?? .metric
        
        // Parse daily progress
        let dailySteps = data["dailySteps"] as? Int ?? 0
        let dailyDistance = data["dailyDistance"] as? Int ?? 0
        let dailyCaloriesBurned = data["dailyCaloriesBurned"] as? Int ?? 0
        
        // Parse timestamps
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        let lastActiveAt = (data["lastActiveAt"] as? Timestamp)?.dateValue() ?? Date()
        
        // Parse economy
        let coins = data["coins"] as? Int ?? 0
        let gems = data["gems"] as? Int ?? 0
        let premiumMember = data["premiumMember"] as? Bool ?? false
        
        // Parse achievements
        let achievementsData = data["myAchievements"] as? [[String: Any]] ?? []
        let myAchievements = achievementsData.compactMap { Achievement.fromFirestore($0) }
        
        // Parse quests
        let currentQuestsData = data["currentQuests"] as? [[String: Any]] ?? []
        let currentQuests = currentQuestsData.compactMap { Quest.fromFirestore($0) }
        
        let completedQuestsData = data["completedQuests"] as? [[String: Any]] ?? []
        let completedQuests = completedQuestsData.compactMap { Quest.fromFirestore($0) }
        
        return User(
            uid: uid,
            email: email,
            username: username,
            selectedAvatar: selectedAvatar,
            totalXP: totalXP,
            totalRuns: totalRuns,
            totalDistance: totalDistance,
            totalCaloriesBurned: totalCaloriesBurned,
            totalSteps: totalSteps,
            myAchievements: myAchievements,
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled,
            soundEffectsEnabled: soundEffectsEnabled,
            units: units,
            dailySteps: dailySteps,
            dailyDistance: dailyDistance,
            dailyCaloriesBurned: dailyCaloriesBurned,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastActiveAt: lastActiveAt,
            currentQuests: currentQuests,
            completedQuests: completedQuests,
            coins: coins,
            gems: gems,
            premiumMember: premiumMember
        )
    }
}
