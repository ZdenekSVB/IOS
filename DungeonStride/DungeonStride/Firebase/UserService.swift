//
//  UserService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class UserService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var currentUser: User?
    private var userListener: ListenerRegistration?
    
    deinit {
        userListener?.remove()
        userListener = nil
    }
    
    // MARK: - User Lifecycle
    
    func createUser(uid: String, email: String, username: String) async throws -> User {
        let newUser = User(
            id: uid,
            email: email,
            username: username
        )
        
        try await db.collection("users").document(uid).setData(newUser.toFirestore())
        currentUser = newUser
        return newUser
    }
    
    func fetchUser(uid: String) async throws -> User {
        let document = try await db.collection("users").document(uid).getDocument()
        
        guard document.exists, let data = document.data() else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        guard let user = User.fromFirestore(documentId: document.documentID, data: data) else {
            throw NSError(domain: "UserService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user data"])
        }
        
        currentUser = user
        return user
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "UserService", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])
        }
        try await db.collection("users").document(userId).setData(user.toFirestore(), merge: true)
        currentUser = user
    }
    
    // MARK: - Daily Reset Logic
    
    func checkAndResetDailyStats(userId: String) async throws -> Bool {
        let user = try await fetchUser(uid: userId)
        var updatedUser = user
        
        if !Calendar.current.isDateInToday(user.lastActiveAt) {
            print("🔄 Resetting daily stats for user: \(userId)")
            updatedUser.resetDaily()
            try await updateUser(updatedUser)
            return true
        } else {
            print("✅ Daily stats are current.")
            return false
        }
    }
}

// MARK: - Activity Logic
extension UserService {
    
    /// Uloží aktivitu a vrátí aktualizovaného uživatele (pro potřeby questů)
    func saveRunActivity(userId: String, activityData: [String: Any], distanceMeters: Int, calories: Int, steps: Int) async throws -> User? {
        let userRef = db.collection("users").document(userId)
        
        // 1. Uložit záznam aktivity
        try await userRef.collection("activities").addDocument(data: activityData)
        
        // 2. Aktualizovat statistiky
        return try await updateStatsAfterActivity(
            userId: userId,
            steps: steps,
            distance: distanceMeters,
            calories: calories
        )
    }
    
    func fetchLastActivity(userId: String) async -> RunActivity? {
        do {
            let snapshot = try await db
                .collection("users")
                .document(userId)
                .collection("activities")
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            guard let doc = snapshot.documents.first else { return nil }
            let data = doc.data()
            
            guard
                let type = data["type"] as? String,
                let distanceKm = data["distance_km"] as? Double,
                let duration = data["duration"] as? Double,
                let calories = data["calories_kcal"] as? Double,
                let pace = data["avg_pace_min_km"] as? Double,
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
            else { return nil }
            
            return RunActivity(
                id: doc.documentID,
                type: type,
                distanceKm: distanceKm,
                duration: duration,
                calories: Int(calories),
                pace: pace,
                timestamp: timestamp
            )
            
        } catch {
            print("Failed to fetch last activity:", error)
            return nil
        }
    }

    private func updateStatsAfterActivity(userId: String, steps: Int, distance: Int, calories: Int) async throws -> User {
        var user: User
        
        if let current = currentUser {
            user = current
        } else {
            user = try await fetchUser(uid: userId)
        }
        
        user.updateActivity(
            steps: steps,
            distance: distance,
            calories: calories,
            isRun: true
        )
        
        let xpEarned = distance / 100
        let coinsEarned = distance / 1000
        
        user.addXP(xpEarned)
        user.addCoins(coinsEarned)
        
        try await updateUser(user)
        return user
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
}

// MARK: - Settings & Listeners
extension UserService {
    func updateSelectedAvatar(uid: String, avatarName: String) async throws {
        let updateData: [String: Any] = [ "selectedAvatar": avatarName, "updatedAt": FieldValue.serverTimestamp() ]
        try await db.collection("users").document(uid).updateData(updateData)
        if var user = currentUser { user.selectedAvatar = avatarName; user.updatedAt = Date(); currentUser = user }
    }
    
    func updateDarkMode(uid: String, isDarkMode: Bool) async throws {
        let updateData: [String: Any] = [ "settings.isDarkMode": isDarkMode, "updatedAt": FieldValue.serverTimestamp() ]
        try await db.collection("users").document(uid).updateData(updateData)
        if var user = currentUser { user.settings.isDarkMode = isDarkMode; user.updatedAt = Date(); currentUser = user }
    }
    
    func updateUserSettings(uid: String, settings: UserSettings) async throws {
        let updateData: [String: Any] = [ "settings": settings.toFirestore(), "updatedAt": FieldValue.serverTimestamp() ]
        try await db.collection("users").document(uid).updateData(updateData)
        if var user = currentUser { user.settings = settings; user.updatedAt = Date(); currentUser = user }
    }
    
    func startListeningForUserUpdates(uid: String) {
        userListener?.remove()
        userListener = db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else { return }
            Task { @MainActor in
                if let user = User.fromFirestore(documentId: snapshot.documentID, data: data) {
                    let oldDM = self.currentUser?.settings.isDarkMode
                    self.currentUser = user
                    if oldDM != user.settings.isDarkMode {
                        NotificationCenter.default.post(name: .darkModeChanged, object: nil, userInfo: ["isDarkMode": user.settings.isDarkMode])
                    }
                }
            }
        }
    }
    
    func stopListeningForUserUpdates() {
        Task { @MainActor in userListener?.remove(); userListener = nil }
    }
}

extension Notification.Name {
    static let darkModeChanged = Notification.Name("darkModeChanged")
}
