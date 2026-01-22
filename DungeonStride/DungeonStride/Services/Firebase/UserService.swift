//
//  UserService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine
import CoreLocation

@MainActor
class UserService: ObservableObject {
    
    private let db = Firestore.firestore()
    
    // ZMĚNA: Potřebujeme vědět, kdy se uživatel přihlásí
    private var authService: AuthService { DIContainer.shared.resolve() }
    
    @Published var currentUser: User?
    
    private var userListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Spustíme sledování přihlášení
        setupAuthListener()
    }
    
    deinit {
        userListener?.remove()
        userListener = nil
    }
    
    // MARK: - Auto-Sync Logic (NOVÉ)
    
    private func setupAuthListener() {
        // Musíme počkat, až bude DI kontejner plně připraven, proto Task
        Task {
            // Sledujeme změny uživatele v AuthService
            authService.$user
                .receive(on: DispatchQueue.main)
                .sink { [weak self] firebaseUser in
                    guard let self = self else { return }
                    
                    if let uid = firebaseUser?.uid {
                        // Uživatel se přihlásil -> začni stahovat data
                        print("👤 UserService: Detected login for \(uid). Starting listener...")
                        self.startListeningForUserUpdates(uid: uid)
                    } else {
                        // Uživatel se odhlásil -> vyčisti data
                        print("👤 UserService: Detected logout. Clearing data.")
                        self.stopListeningForUserUpdates()
                        self.currentUser = nil
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - User Lifecycle
    
    func createUser(uid: String, email: String, username: String) async throws -> User {
        let newUser = User(
            id: uid,
            email: email,
            username: username
        )
        
        try await db.collection("users").document(uid).setData(newUser.toFirestore())
        // Nemusíme nastavovat currentUser manuálně, listener to zachytí
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
        
        self.currentUser = user
        return user
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "UserService", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])
        }
        try await db.collection("users").document(userId).setData(user.toFirestore(), merge: true)
        // Listener se postará o update UI, ale pro rychlou odezvu můžeme nastavit i lokálně:
        self.currentUser = user
    }
    
    // MARK: - Daily Reset Logic
    
    func checkAndResetDailyStats(userId: String) async throws -> Bool {
        // Zde raději fetchujeme čerstvá data, abychom nepracovali se starými
        let user = try await fetchUser(uid: userId)
        var updatedUser = user
        
        if !Calendar.current.isDateInToday(user.lastActiveAt) {
            print("🔄 Resetting daily stats for user: \(userId)")
            updatedUser.resetDaily()
            try await updateUser(updatedUser)
            return true
        } else {
            return false
        }
    }
}

// MARK: - Activity Logic
extension UserService {
    
    func saveRunActivity(userId: String, activityData: [String: Any], distanceMeters: Int, calories: Int, steps: Int) async throws -> User? {
        let userRef = db.collection("users").document(userId)
        
        try await userRef.collection("activities").addDocument(data: activityData)
        
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
            
            var parsedCoordinates: [CLLocationCoordinate2D]? = nil
            
            if let rawCoordinates = data["route_coordinates"] as? [[String: Double]] {
                parsedCoordinates = rawCoordinates.compactMap { point in
                    guard let lat = point["lat"], let lon = point["lon"] else { return nil }
                    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
            }
            
            return RunActivity(
                id: doc.documentID,
                type: type,
                distanceKm: distanceKm,
                duration: duration,
                calories: Int(calories),
                pace: pace,
                timestamp: timestamp,
                routeCoordinates: parsedCoordinates
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
        
        // Lokální update (pokud listener ještě nezareagoval)
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
    }
    
    func updateDarkMode(uid: String, isDarkMode: Bool) async throws {
        let updateData: [String: Any] = [ "settings.isDarkMode": isDarkMode, "updatedAt": FieldValue.serverTimestamp() ]
        try await db.collection("users").document(uid).updateData(updateData)
    }
    
    func updateUserSettings(uid: String, settings: UserSettings) async throws {
        let updateData: [String: Any] = [ "settings": settings.toFirestore(), "updatedAt": FieldValue.serverTimestamp() ]
        try await db.collection("users").document(uid).updateData(updateData)
    }
    
    func startListeningForUserUpdates(uid: String) {
        // Pokud už posloucháme stejného uživatele, nic nedělej
        if currentUser?.id == uid && userListener != nil { return }
        
        userListener?.remove()
        print("🎧 Starting Firestore listener for user: \(uid)")
        
        userListener = db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ User listener error: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                print("⚠️ User document does not exist yet (might be creating).")
                return
            }
            
            Task { @MainActor in
                if let user = User.fromFirestore(documentId: snapshot.documentID, data: data) {
                    let oldDM = self.currentUser?.settings.isDarkMode
                    self.currentUser = user
                    
                    // Notifikace pro ThemeManager (pokud se změnilo téma z jiného zařízení)
                    if let oldDM = oldDM, oldDM != user.settings.isDarkMode {
                        NotificationCenter.default.post(name: .darkModeChanged, object: nil, userInfo: ["isDarkMode": user.settings.isDarkMode])
                    }
                }
            }
        }
    }
    
    func stopListeningForUserUpdates() {
        userListener?.remove()
        userListener = nil
        print("🛑 Stopped user listener.")
    }
}

extension Notification.Name {
    static let darkModeChanged = Notification.Name("darkModeChanged")
}
