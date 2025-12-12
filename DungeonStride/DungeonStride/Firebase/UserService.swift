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
}

// MARK: - Activity Logic
extension UserService {
    func saveRunActivity(userId: String, activityData: [String: Any], distanceMeters: Int, calories: Int, steps: Int) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await userRef.collection("activities").addDocument(data: activityData)
        
        if var user = currentUser {
            let xpEarned = distanceMeters / 100
            let coinsEarned = distanceMeters / 1000
            
            user.addXP(xpEarned)
            user.addCoins(coinsEarned)
            user.updateDailyProgress(steps: steps, distance: distanceMeters, calories: calories)
            
            try await updateUser(user)
            self.currentUser = user
            print("✅ Activity saved and user stats updated.")
        }
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
