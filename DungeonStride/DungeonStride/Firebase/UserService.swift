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
        
        func migrateUserData(from oldUid: String, to newUid: String) async throws {
            let oldDocument = try await db.collection("users").document(oldUid).getDocument()
            
            guard oldDocument.exists,
                  var data = oldDocument.data() else {
                throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Old user not found"])
            }
            
            data.removeValue(forKey: "uid")
            
            try await db.collection("users").document(newUid).setData(data)
            
            try await db.collection("users").document(oldUid).delete()
        }
}
