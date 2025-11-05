//
//  UserService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine

class UserService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var currentUser: User?
    
    func createUser(uid: String, email: String, username: String) async throws -> User {
        let newUser = User(
            uid: uid,
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
            coins: 100, // Startovní coins
            gems: 10,   // Startovní gems
            premiumMember: false
        )
        
        try await db.collection("users").document(uid).setData(newUser.toFirestore())
        
        await MainActor.run {
            self.currentUser = newUser
        }
        
        return newUser
    }
    
    func fetchUser(uid: String) async throws -> User {
        let document = try await db.collection("users").document(uid).getDocument()
        
        guard let data = document.data(),
              let user = User.fromFirestore(data) else {
            // Pokud uživatel neexistuje, vytvoříme ho
            print("⚠️ User not found in Firestore, creating new user...")
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        await MainActor.run {
            self.currentUser = user
        }
        
        return user
    }
    
    func updateUser(_ user: User) async throws {
        try await db.collection("users").document(user.uid).setData(user.toFirestore(), merge: true)
        
        await MainActor.run {
            self.currentUser = user
        }
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
            await MainActor.run {
                self.currentUser = user
            }
        }
    }
    
    // Pomocná metoda pro získání uživatele podle UID
    func getUser(by uid: String) async -> User? {
        do {
            return try await fetchUser(uid: uid)
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
}
