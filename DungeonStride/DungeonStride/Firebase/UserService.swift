//
// UserService.swift
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class UserService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var currentUser: User?
    private var userListener: ListenerRegistration?
    
    // MARK: - User Management
    
    func createUser(uid: String, email: String, username: String) async throws -> User {
        let newUser = User(
            id: uid,
            email: email,
            username: username,
            selectedAvatar: "default",
            stats: PlayerStats(hp: 100, maxHP: 100, physicalDamage: 10, magicDamage: 5, defense: 5, speed: 10, evasion: 0.05),
            coins: 100,
            gems: 10,
            premiumMember: false,
            totalXP: 0,
            activityStats: ActivityStats(totalRuns: 0, totalDistance: 0, totalCaloriesBurned: 0, totalSteps: 0),
            dailyActivity: DailyActivity(dailySteps: 0, dailyDistance: 0, dailyCaloriesBurned: 0),
            settings: UserSettings(isDarkMode: false, notificationsEnabled: true, soundEffectsEnabled: true, units: .metric),
            myAchievements: [],
            currentQuests: [],
            completedQuests: [],
            createdAt: Date(),
            updatedAt: Date(),
            lastActiveAt: Date()
        )
        
        try await db.collection("users").document(uid).setData(newUser.toFirestore())
        currentUser = newUser
        return newUser
    }
    
    // MARK: - Activity Saving
    
    /// Uloží aktivitu do subkolekce a aktualizuje statistiky uživatele
    func saveRunActivity(userId: String, activityData: [String: Any], distanceMeters: Int, calories: Int, steps: Int) async throws {
        let userRef = db.collection("users").document(userId)
        
        // 1. Uložit záznam do historie (users/{uid}/activities/{autoID})
        try await userRef.collection("activities").addDocument(data: activityData)
        
        // 2. Aktualizovat statistiky uživatele (XP, Coins, TotalStats)
        // Získáme aktuální data, abychom mohli přičíst hodnoty
        if var user = currentUser {
            
            // Logika odměn (např. 1 XP za 100 metrů, 1 Coin za 1 km)
            let xpEarned = distanceMeters / 100
            let coinsEarned = distanceMeters / 1000
            
            user.addXP(xpEarned)
            user.addCoins(coinsEarned)
            
            // Aktualizace denních a celkových statistik
            user.updateDailyProgress(steps: steps, distance: distanceMeters, calories: calories)
            
            // Uložíme aktualizovaného uživatele zpět do Firestore
            try await updateUser(user)
            
            // Lokální aktualizace
            self.currentUser = user
            print("✅ Activity saved and user stats updated.")
        }
    }
    
    // MARK: - Avatar Management
    func updateSelectedAvatar(uid: String, avatarName: String) async throws {
        let updateData: [String: Any] = [
            "selectedAvatar": avatarName,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(uid).updateData(updateData)
        
        if var user = currentUser {
            user.selectedAvatar = avatarName
            user.updatedAt = Date()
            currentUser = user
        }
    }
    
    func fetchUser(uid: String) async throws -> User {
        let document = try await db.collection("users").document(uid).getDocument()
        
        guard document.exists,
              let data = document.data() else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        guard let user = User.fromFirestore(documentId: document.documentID, data: data) else {
            throw NSError(domain: "UserService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user data"])
        }
        
        currentUser = user
        return user
    }
    
    // MARK: - Real-time Updates
    
    func startListeningForUserUpdates(uid: String) {
        userListener?.remove()
        
        userListener = db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error listening to user updates: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let data = snapshot.data() else {
                print("⚠️ User document doesn't exist")
                return
            }
            
            Task { @MainActor in
                if let user = User.fromFirestore(documentId: snapshot.documentID, data: data) {
                    let oldDarkMode = self.currentUser?.settings.isDarkMode
                    let newDarkMode = user.settings.isDarkMode
                    
                    self.currentUser = user
                    
                    if oldDarkMode != newDarkMode {
                        NotificationCenter.default.post(
                            name: .darkModeChanged,
                            object: nil,
                            userInfo: ["isDarkMode": newDarkMode]
                        )
                    }
                }
            }
        }
    }
    
    func stopListeningForUserUpdates() {
        Task { @MainActor in
            userListener?.remove()
            userListener = nil
        }
    }
    
    // MARK: - Settings & Update Helpers
    
    func updateDarkMode(uid: String, isDarkMode: Bool) async throws {
        let updateData: [String: Any] = [
            "settings.isDarkMode": isDarkMode,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(uid).updateData(updateData)
        if var user = currentUser {
            user.settings.isDarkMode = isDarkMode
            user.updatedAt = Date()
            currentUser = user
        }
    }
    
    func updateUserSettings(uid: String, settings: UserSettings) async throws {
        let updateData: [String: Any] = [
            "settings": settings.toFirestore(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(uid).updateData(updateData)
        if var user = currentUser {
            user.settings = settings
            user.updatedAt = Date()
            currentUser = user
        }
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "UserService", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])
        }
        try await db.collection("users").document(userId).setData(user.toFirestore(), merge: true)
        currentUser = user
    }
    
    func updateLastActive(uid: String) async throws {
        let updateData: [String: Any] = [
            "lastActiveAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(uid).updateData(updateData)
        if var user = currentUser {
            user.lastActiveAt = Date()
            user.updatedAt = Date()
            currentUser = user
        }
    }
    
    deinit {
        userListener?.remove()
        userListener = nil
    }
}

// MARK: - Extensions
extension Notification.Name {
    static let darkModeChanged = Notification.Name("darkModeChanged")
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
