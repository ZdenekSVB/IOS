//
//  AuthViewModel.swift
//  DungeonStride
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthViewModel: ObservableObject {
    
    private var db: Firestore?
    private let userService = UserService()
    private var themeManager: ThemeManager?
    
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    @Published var isRegistered = false
    @Published var isLoggedIn = false
    @Published var currentUserUID: String?
    @Published var currentUserEmail: String?
    
    init() {
        // Počkejte s inicializací Firestore až po konfiguraci Firebase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Task { @MainActor in
                self.db = Firestore.firestore()
                await self.checkIfUserIsLoggedIn()
            }
        }
    }
    func setupThemeManager(_ themeManager: ThemeManager) {
        self.themeManager = themeManager
    }
    
    private func getDB() -> Firestore {
        guard let db = db else {
            return Firestore.firestore()
        }
        return db
    }
    
    // MARK: - Email/Password Authentication
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        print("🔐 Attempting login for: \(email)")
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    let errorMsg = self.parseAuthError(error)
                    self.errorMessage = errorMsg
                    print("❌ Login failed: \(errorMsg)")
                    return
                }
                
                guard let user = result?.user else {
                    self.errorMessage = "Login failed - no user data"
                    print("❌ Login failed - no user data")
                    return
                }
                
                print("✅ Login successful: \(user.email ?? "Unknown")")
                self.currentUserUID = user.uid
                self.currentUserEmail = user.email
                self.isLoggedIn = true
                self.errorMessage = ""
                
                // Načíst uživatelská data z Firestore
                await self.loadUserData(uid: user.uid)
                
                await self.assignDailyQuestsIfNeeded(for: user.uid)

                // Aktualizujte Firestore
                self.updateLastLogin(uid: user.uid)
                self.setupUserNotifications()
            }
        }
    }
    
    func register() {
        // Validace
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill in all fields"
            return
        }
        
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters"
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            self.errorMessage = "Please enter a valid email address"
            return
        }

        isLoading = true
        errorMessage = ""
        
        print("📝 Starting registration for: \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    let errorMsg = self.parseAuthError(error)
                    self.errorMessage = errorMsg
                    print("❌ Registration failed: \(errorMsg)")
                    return
                }
                
                guard let user = result?.user else {
                    self.isLoading = false
                    self.errorMessage = "Failed to create user account"
                    print("❌ Registration failed - no user data")
                    return
                }
                
                print("✅ Firebase Auth success: \(user.uid)")
                await self.createUserInFirestore(uid: user.uid)
            }
        }
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() async {
        // Kontrola Google Client ID (bez warningu)
        guard FirebaseApp.app()?.options.clientID != nil else {
            errorMessage = "Missing Google Client ID"
            print("❌ Missing Google Client ID")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // Získání "root view controlleru" - není async operace
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                errorMessage = "Unable to find root view controller"
                isLoading = false
                return
            }
            
            // Přihlášení uživatele přes Google - TOTO JE async operace
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            
            guard let idToken = signInResult.user.idToken?.tokenString else {
                errorMessage = "Missing ID token"
                isLoading = false
                return
            }
            
            let accessToken = signInResult.user.accessToken.tokenString
            
            // Přihlášení do Firebase pomocí Google credentialu - TOTO JE async operace
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let result = try await Auth.auth().signIn(with: credential)
            
            // Získáme přihlášeného uživatele
            let user = result.user
            
            currentUserUID = user.uid
            currentUserEmail = user.email
            isLoggedIn = true
            errorMessage = ""
            
            print("✅ Google Sign-In successful: \(user.email ?? "Unknown")")
            
            // Ulož nebo aktualizuj data o uživateli ve Firestore - TOTO JE async operace
            await handleGoogleUser(user: user)
            await self.assignDailyQuestsIfNeeded(for: user.uid)

            
        } catch {
            print("❌ Google Sign-In error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - User Management
    
    private func createUserInFirestore(uid: String) async {
        do {
            // Vytvořit nového uživatele pomocí UserService
            let newUser = try await userService.createUser(
                uid: uid,
                email: email,
                username: username
            )
            
            isLoading = false
            currentUserUID = uid
            currentUserEmail = email
            isLoggedIn = true
            isRegistered = true
            errorMessage = ""
            
            print("🎉 Registration completed successfully")
            print("👤 User created: \(newUser.username)")
            
        } catch {
            isLoading = false
            errorMessage = "Failed to create user profile: \(error.localizedDescription)"
            print("❌ Firestore user creation failed: \(error.localizedDescription)")
            
            // Pokusíme se smazat auth účet, když selže Firestore
            deleteAuthAccount(uid: uid)
        }
    }
    
    private func handleGoogleUser(user: FirebaseAuth.User) async {
        do {
            // Zkusíme načíst existujícího uživatele
            let existingUser = try? await userService.fetchUser(uid: user.uid)
            
            if existingUser == nil {
                // Uživatel se přihlašuje poprvé – vytvoř nový profil
                let googleUsername = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "GoogleUser"
                
                let newUser = try await userService.createUser(
                    uid: user.uid,
                    email: user.email ?? "",
                    username: googleUsername
                )
                
                print("🎉 Google user created: \(newUser.username)")
            } else {
                // Uživatel již existuje - aktualizuj poslední přihlášení
                try await userService.updateLastActive(uid: user.uid)
                print("🔁 Existing Google user loaded")
            }
            
            isLoading = false
            setupUserNotifications()
            
        } catch {
            isLoading = false
            errorMessage = "Failed to handle Google user: \(error.localizedDescription)"
            print("❌ Google user handling failed: \(error.localizedDescription)")
        }
    }
    
    private func loadUserData(uid: String) async {
        do {
            let user = try await userService.fetchUser(uid: uid)
            print("✅ User data loaded: \(user.username)")
            
            // Aktualizujte ThemeManager s nastavením uživatele
            await MainActor.run {
                themeManager?.setDarkMode(user.settings.isDarkMode)
            }
        } catch {
            print("⚠️ Failed to load user data: \(error.localizedDescription)")
            if let authUser = Auth.auth().currentUser {
                await createUserFromAuthUser(authUser)
            }
        }
    }
    
    private func createUserFromAuthUser(_ authUser: FirebaseAuth.User) async {
        do {
            let username = authUser.displayName ?? authUser.email?.components(separatedBy: "@").first ?? "User"
            let _ = try await userService.createUser(
                uid: authUser.uid,
                email: authUser.email ?? "",
                username: username
            )
            
            print("✅ Created user profile from auth data")
        } catch {
            print("❌ Failed to create user from auth: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    func checkIfUserIsLoggedIn() async {
        if let user = Auth.auth().currentUser {
            currentUserUID = user.uid
            currentUserEmail = user.email
            isLoggedIn = true
            print("✅ User already logged in: \(user.email ?? "Unknown")")
            
            // Načíst uživatelská data
            await loadUserData(uid: user.uid)
            await self.assignDailyQuestsIfNeeded(for: user.uid)

        } else {
            isLoggedIn = false
            print("ℹ️ No user logged in")
        }
    }
    
    // V AuthViewModel uprav metodu updateLastLogin:
    private func updateLastLogin(uid: String) {
        let updateData: [String: Any] = [
            "lastActiveAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        getDB().collection("users").document(uid).updateData(updateData) { error in
            if let error = error {
                print("⚠️ Failed to update last login: \(error.localizedDescription)")
            } else {
                print("✅ Last login updated")
            }
        }
    }
    
    private func deleteAuthAccount(uid: String) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("⚠️ Failed to delete auth account: \(error.localizedDescription)")
            } else {
                print("🗑️ Auth account deleted due to Firestore failure")
            }
        }
    }
    
    func assignDailyQuestsIfNeeded(for uid: String) async {
            let db = getDB()
            let userRef = db.collection("users").document(uid)

            do {
                let userDoc = try await userRef.getDocument()
                let lastDate = (userDoc.data()?["lastDailyQuestDate"] as? Timestamp)?.dateValue()
                let now = Date()

                // Pokud je poslední login dnes → nic nedělej
                if let lastDate = lastDate, Calendar.current.isDate(lastDate, inSameDayAs: now) {
                    print("🟢 Daily quests already assigned for today")
                    return
                }

                // Jinak vytvoř 3 nové denní questy
                let allQuestsSnapshot = try await db.collection("quests").getDocuments()
                let allQuests = allQuestsSnapshot.documents.compactMap { doc -> [String: Any]? in
                    doc.data()
                }

                guard allQuests.count >= 3 else {
                    print("⚠️ Not enough quests to assign (found \(allQuests.count))")
                    return
                }

                let shuffled = allQuests.shuffled().prefix(3)
                let dailyQuests = shuffled.map { quest -> [String: Any] in
                    var q = quest
                    q["isCompleted"] = false
                    q["progress"] = 0
                    q["assignedAt"] = FieldValue.serverTimestamp()
                    return q
                }

                // Uložit do users/{uid}/dailyQuests
                let dailyQuestsRef = userRef.collection("dailyQuests")

                // Smazat staré daily questy
                let oldDocs = try await dailyQuestsRef.getDocuments()
                for doc in oldDocs.documents {
                    try await dailyQuestsRef.document(doc.documentID).delete()
                }

                // Zapsat nové
                for questData in dailyQuests {
                    let id = questData["id"] as? String ?? UUID().uuidString
                    try await dailyQuestsRef.document(id).setData(questData)
                }

                // Aktualizovat timestamp posledního přiřazení
                try await userRef.updateData(["lastDailyQuestDate": FieldValue.serverTimestamp()])

                print("✨ Assigned new daily quests for user: \(uid)")
            } catch {
                print("❌ Failed to assign daily quests: \(error.localizedDescription)")
            }
        }
    
    func logout() {
        do {
            if let email = Auth.auth().currentUser?.email {
                print("👋 Logging out: \(email)")
            }
            try Auth.auth().signOut()
            
            // Reset stavu
            isLoggedIn = false
            isRegistered = false
            currentUserUID = nil
            currentUserEmail = nil
            email = ""
            password = ""
            username = ""
            errorMessage = ""
            
            // Resetovat UserService
            userService.currentUser = nil
            
            // Resetovat ThemeManager na výchozí nastavení
            themeManager?.setDarkMode(false)
            
            print("✅ Logout successful")
        } catch {
            errorMessage = "Logout error: \(error.localizedDescription)"
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }
    
    // Pomocná metoda pro lepší error messages
    private func parseAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address"
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak"
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection"
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password"
        default:
            return error.localizedDescription
        }
    }
    
    private func setupUserNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("✅ Notifications authorized")
            case .denied:
                print("❌ Notifications denied")
            case .notDetermined:
                print("❓ Notifications not determined")
            case .ephemeral:
                print("❓ Notifications ephemeral")
            @unknown default:
                print("❓ Unknown notification status")
            }
        }
    }
}
