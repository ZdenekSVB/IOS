//
//  User.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore

// MARK: - User

struct User: Identifiable, Codable {
    @DocumentID var id: String?

    let email: String
    let username: String
    var selectedAvatar: String = "default"

    // RPG Stats (Síla, Obrana...)
    var stats: PlayerStats = .default
    
    // Statistiky aktivit
    var activityStats: ActivityStats = .empty
    // Denní resetované statistiky
    var dailyActivity: DailyActivity = .empty

    var settings: UserSettings = .default

    var coins: Int = 0
    var totalXP: Int = 0
    
    // Počítadlo splněných misí (nové místo achievementů)
    var totalQuestsCompleted: Int = 0

    var equippedIds: [String: String] = [:]
    
    // Data obchodu (Definováno v ShopModels.swift)
    var shopData: UserShopData = .empty

    let createdAt: Date
    var updatedAt: Date
    var lastActiveAt: Date

    // MARK: - Computed

    var uid: String { id ?? "" }

    var level: Int {
        (totalXP / 100) + 1
    }

    var levelProgress: Double {
        Double(totalXP % 100) / 100.0
    }

    var xpToNextLevel: Int {
        (level * 100) - totalXP
    }

    // MARK: - Init

    init(
        id: String? = nil,
        email: String,
        username: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastActiveAt = lastActiveAt
    }

    // MARK: - Mutating helpers

    mutating func addXP(_ amount: Int) {
        totalXP += amount
        updatedAt = Date()
    }

    mutating func addCoins(_ amount: Int) {
        coins += amount
        updatedAt = Date()
    }
    
    mutating func incrementQuestCount() {
        totalQuestsCompleted += 1
        updatedAt = Date()
    }

    mutating func resetDaily() {
        dailyActivity = .empty
        updatedAt = Date()
    }

    mutating func updateActivity(
        steps: Int,
        distance: Int,
        calories: Int,
        isRun: Bool
    ) {
        // Update Daily
        dailyActivity.dailySteps += steps
        dailyActivity.dailyDistance += distance
        dailyActivity.dailyCaloriesBurned += calories

        // Update Total
        activityStats.totalSteps += steps
        activityStats.totalDistance += distance
        activityStats.totalCaloriesBurned += calories
        
        if isRun {
            activityStats.totalRuns += 1
        }

        updatedAt = Date()
    }

    // MARK: - Firestore Mapping

    func toFirestore() -> [String: Any] {
        [
            "email": email,
            "username": username,
            "selectedAvatar": selectedAvatar,
            "stats": stats.toFirestore(),
            "activityStats": activityStats.toFirestore(),
            "dailyActivity": dailyActivity.toFirestore(),
            "settings": settings.toFirestore(),
            "coins": coins,
            "totalXP": totalXP,
            "totalQuestsCompleted": totalQuestsCompleted,
            "equippedIds": equippedIds,
            "shopData": shopData.toFirestore(),
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "lastActiveAt": Timestamp(date: lastActiveAt)
        ]
    }

    static func fromFirestore(
        documentId: String,
        data: [String: Any]
    ) -> User? {
        guard
            let email = data["email"] as? String,
            let username = data["username"] as? String
        else { return nil }

        var user = User(
            id: documentId,
            email: email,
            username: username,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastActiveAt: (data["lastActiveAt"] as? Timestamp)?.dateValue() ?? Date()
        )

        user.selectedAvatar = data["selectedAvatar"] as? String ?? "default"
        user.coins = data["coins"] as? Int ?? 0
        user.totalXP = data["totalXP"] as? Int ?? 0
        user.totalQuestsCompleted = data["totalQuestsCompleted"] as? Int ?? 0
        user.equippedIds = data["equippedIds"] as? [String: String] ?? [:]

        if let dict = data["stats"] as? [String: Any] {
            user.stats = PlayerStats.fromFirestore(dict)
        }

        if let dict = data["activityStats"] as? [String: Any] {
            user.activityStats = ActivityStats.fromFirestore(dict)
        }

        if let dict = data["dailyActivity"] as? [String: Any] {
            user.dailyActivity = DailyActivity.fromFirestore(dict)
        }
        
        if let dict = data["settings"] as? [String: Any] {
            user.settings = UserSettings.fromFirestore(dict)
        }
        
        if let dict = data["shopData"] as? [String: Any] {
            user.shopData = UserShopData.fromFirestore(dict)
        }

        return user
    }
}

// MARK: - Supporting Models

struct PlayerStats: Codable {
    var hp: Int
    var maxHP: Int
    var physicalDamage: Int
    var magicDamage: Int
    var defense: Int
    var speed: Int
    var evasion: Double

    static let `default` = PlayerStats(
        hp: 100,
        maxHP: 100,
        physicalDamage: 10,
        magicDamage: 5,
        defense: 5,
        speed: 10,
        evasion: 0.05
    )

    func toFirestore() -> [String: Any] {
        [
            "hp": hp,
            "maxHP": maxHP,
            "physicalDamage": physicalDamage,
            "magicDamage": magicDamage,
            "defense": defense,
            "speed": speed,
            "evasion": evasion
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> PlayerStats {
        PlayerStats(
            hp: data["hp"] as? Int ?? 100,
            maxHP: data["maxHP"] as? Int ?? 100,
            physicalDamage: data["physicalDamage"] as? Int ?? 10,
            magicDamage: data["magicDamage"] as? Int ?? 5,
            defense: data["defense"] as? Int ?? 5,
            speed: data["speed"] as? Int ?? 10,
            evasion: data["evasion"] as? Double ?? 0.0
        )
    }
}

struct ActivityStats: Codable {
    var totalRuns: Int
    var totalDistance: Int
    var totalCaloriesBurned: Int
    var totalSteps: Int

    static let empty = ActivityStats(
        totalRuns: 0,
        totalDistance: 0,
        totalCaloriesBurned: 0,
        totalSteps: 0
    )

    func toFirestore() -> [String: Any] {
        [
            "totalRuns": totalRuns,
            "totalDistance": totalDistance,
            "totalCaloriesBurned": totalCaloriesBurned,
            "totalSteps": totalSteps
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> ActivityStats {
        ActivityStats(
            totalRuns: data["totalRuns"] as? Int ?? 0,
            totalDistance: data["totalDistance"] as? Int ?? 0,
            totalCaloriesBurned: data["totalCaloriesBurned"] as? Int ?? 0,
            totalSteps: data["totalSteps"] as? Int ?? 0
        )
    }
}

struct DailyActivity: Codable {
    var dailySteps: Int
    var dailyDistance: Int
    var dailyCaloriesBurned: Int

    static let empty = DailyActivity(
        dailySteps: 0,
        dailyDistance: 0,
        dailyCaloriesBurned: 0
    )

    func toFirestore() -> [String: Any] {
        [
            "dailySteps": dailySteps,
            "dailyDistance": dailyDistance,
            "dailyCaloriesBurned": dailyCaloriesBurned
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> DailyActivity {
        DailyActivity(
            dailySteps: data["dailySteps"] as? Int ?? 0,
            dailyDistance: data["dailyDistance"] as? Int ?? 0,
            dailyCaloriesBurned: data["dailyCaloriesBurned"] as? Int ?? 0
        )
    }
}

struct UserSettings: Codable {
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    var soundEffectsEnabled: Bool
    var units: DistanceUnit

    static let `default` = UserSettings(
        isDarkMode: false,
        notificationsEnabled: true,
        soundEffectsEnabled: true,
        units: .metric
    )

    func toFirestore() -> [String: Any] {
        [
            "isDarkMode": isDarkMode,
            "notificationsEnabled": notificationsEnabled,
            "soundEffectsEnabled": soundEffectsEnabled,
            "units": units.rawValue
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> UserSettings {
        UserSettings(
            isDarkMode: data["isDarkMode"] as? Bool ?? false,
            notificationsEnabled: data["notificationsEnabled"] as? Bool ?? true,
            soundEffectsEnabled: data["soundEffectsEnabled"] as? Bool ?? true,
            units: DistanceUnit(rawValue: data["units"] as? String ?? "metric") ?? .metric
        )
    }
}
