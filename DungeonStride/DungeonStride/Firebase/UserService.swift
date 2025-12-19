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
    
    func checkAndResetDailyStats(userId: String) async throws {
        // 1. Načteme aktuální stav uživatele
        let user = try await fetchUser(uid: userId)
        var updatedUser = user
        
        // 2. Zkontrolujeme, zda poslední aktivita byla "dnes"
        if !Calendar.current.isDateInToday(user.lastActiveAt) {
            print("🔄 Resetting daily stats for user: \(userId)")
            updatedUser.resetDaily()
            
            // 3. Aktualizujeme uživatele v DB
            try await updateUser(updatedUser)
        } else {
            print("✅ Daily stats are current.")
        }
    }
}

// MARK: - Activity Logic
extension UserService {
    
    func saveRunActivity(userId: String, activityData: [String: Any], distanceMeters: Int, calories: Int, steps: Int) async throws {
        let userRef = db.collection("users").document(userId)
        
        // 1. Uložit záznam aktivity do sub-kolekce
        try await userRef.collection("activities").addDocument(data: activityData)
        
        // 2. Aktualizovat statistiky uživatele (Total a Daily)
        try await updateStatsAfterActivity(
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
            else {
                return nil
            }
            
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

    private func updateStatsAfterActivity(userId: String, steps: Int, distance: Int, calories: Int) async throws {
        // FIX: Správná deklarace proměnné 'user' před použitím
        var user: User
        
        // Pokud máme uživatele v paměti, použijeme ho. Jinak ho stáhneme.
        if let current = currentUser {
            user = current
        } else {
            user = try await fetchUser(uid: userId)
        }
        
        

        // Nyní máme jistotu, že 'user' existuje a můžeme ho upravovat
        user.updateActivity(
            steps: steps,
            distance: distance,
            calories: calories,
            isRun: true
        )
        
        // Výpočet odměn
        let xpEarned = distance / 100
        let coinsEarned = distance / 1000
        
        user.addXP(xpEarned)
        user.addCoins(coinsEarned)
        
        // Uložení do Firebase
        try await updateUser(user)
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

// MARK: - Settings & Customization
extension UserService {
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
}

// MARK: - Listeners
extension UserService {
    func startListeningForUserUpdates(uid: String) {
        userListener?.remove()
        
        userListener = db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error listening to user updates: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
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
}

extension Notification.Name {
    static let darkModeChanged = Notification.Name("darkModeChanged")
}
