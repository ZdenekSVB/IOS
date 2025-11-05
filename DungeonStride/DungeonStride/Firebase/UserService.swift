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
    
    func createUser(uid: String, email: String, username: String) async throws -> User {
        let newUser = User(
            id: uid, // Document ID bude uid
            email: email,
            username: username,
            selectedAvatar: "default",
            totalXP: 0,
            totalRuns: 0,
            totalDistance: 0,
            totalCaloriesBurned: 0,
            totalSteps: 0,
            myAchievements: [],
            isDarkMode: false,
            notificationsEnabled: true,
            soundEffectsEnabled: true,
            units: .metric,
            dailySteps: 0,
            dailyDistance: 0,
            dailyCaloriesBurned: 0,
            createdAt: Date(),
            updatedAt: Date(),
            lastActiveAt: Date(),
            currentQuests: [],
            completedQuests: [],
            coins: 100,
            gems: 10,
            premiumMember: false
        )
        
        // Uložíme dokument s ID = uid, ale bez uid field uvnitř
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
        
        // Předáme document ID (uid) a data
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
    
    func updateLastActive(uid: String) async throws {
        let updateData: [String: Any] = [
            "lastActiveAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(uid).updateData(updateData)
        
        // Aktualizovat lokálního uživatele
        if var user = currentUser {
            user.lastActiveAt = Date()
            user.updatedAt = Date()
            currentUser = user
        }
    }
    
    func getUser(by uid: String) async -> User? {
        do {
            return try await fetchUser(uid: uid)
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    // Pomocná metoda pro migraci starých dat (pokud potřebuješ)
    func migrateUserData(from oldUid: String, to newUid: String) async throws {
        let oldDocument = try await db.collection("users").document(oldUid).getDocument()
        
        guard oldDocument.exists,
              var data = oldDocument.data() else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Old user not found"])
        }
        
        // Odstraníme uid field z dat
        data.removeValue(forKey: "uid")
        
        // Vytvoříme nový dokument bez uid field
        try await db.collection("users").document(newUid).setData(data)
        
        // Smazat starý dokument (volitelné)
        try await db.collection("users").document(oldUid).delete()
    }
}
