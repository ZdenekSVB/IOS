// UserService.swift
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
    
    // MARK: - Real-time Updates for Settings
    
    func startListeningForUserUpdates(uid: String) {
        // Nejprve odstraníme existující listener
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
                    
                    // Notifikujte o změně dark módu
                    if oldDarkMode != newDarkMode {
                        print("🎨 Dark mode changed to: \(newDarkMode)")
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
    
    // MARK: - Settings Management
    
    func updateDarkMode(uid: String, isDarkMode: Bool) async throws {
        let updateData: [String: Any] = [
            "settings.isDarkMode": isDarkMode,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(uid).updateData(updateData)
        
        // Lokálně aktualizujte uživatele
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
        
        // Lokálně aktualizujte uživatele
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
        Task { @MainActor in
            userListener?.remove()
            userListener = nil
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let darkModeChanged = Notification.Name("darkModeChanged")
}

// MARK: - UserSettings Extension
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
        
        // Použijte DistanceUnit místo Units
        let units: DistanceUnit
        if let existingUnits = DistanceUnit(rawValue: unitsString) {
            units = existingUnits
        } else {
            units = .metric // výchozí hodnota
        }
        
        return UserSettings(
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled,
            soundEffectsEnabled: soundEffectsEnabled,
            units: units // ← OPRAVA: použijte instanci 'units', ne typ 'DistanceUnit'
        )
    }
}
