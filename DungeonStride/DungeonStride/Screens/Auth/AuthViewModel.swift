//
//  AuthViewModel.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    private var db: Firestore?
    
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
            self.db = Firestore.firestore()
            self.checkIfUserIsLoggedIn()
        }
    }
    
    private func getDB() -> Firestore {
        guard let db = db else {
            // Fallback - vytvořte novou instanci pokud selže
            return Firestore.firestore()
        }
        return db
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        print("🔐 Attempting login for: \(email)")
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    let errorMsg = self?.parseAuthError(error) ?? error.localizedDescription
                    self?.errorMessage = errorMsg
                    print("❌ Login failed: \(errorMsg)")
                    return
                }
                
                guard let user = result?.user else {
                    self?.errorMessage = "Login failed - no user data"
                    print("❌ Login failed - no user data")
                    return
                }
                
                print("✅ Login successful: \(user.email ?? "Unknown")")
                self?.currentUserUID = user.uid
                self?.currentUserEmail = user.email
                self?.isLoggedIn = true
                self?.errorMessage = ""
                
                // Aktualizujte Firestore
                self?.updateLastLogin(uid: user.uid)
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if let user = Auth.auth().currentUser {
            currentUserUID = user.uid
            currentUserEmail = user.email
            isLoggedIn = true
            print("✅ User already logged in: \(user.email ?? "Unknown")")
        } else {
            isLoggedIn = false
            print("ℹ️ No user logged in")
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
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    let errorMsg = self?.parseAuthError(error) ?? error.localizedDescription
                    self?.errorMessage = errorMsg
                    print("❌ Registration failed: \(errorMsg)")
                    return
                }
                
                guard let user = result?.user else {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to create user account"
                    print("❌ Registration failed - no user data")
                    return
                }
                
                print("✅ Firebase Auth success: \(user.uid)")
                self?.saveUserToFirestore(uid: user.uid)
            }
        }
    }
    
    private func saveUserToFirestore(uid: String) {
        let userData: [String: Any] = [
            "username": username,
            "email": email,
            "imageUrl": "",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "lastLoggedIn": FieldValue.serverTimestamp()
        ]

        print("💾 Saving to Firestore: \(uid)")
        
        getDB().collection("users").document(uid).setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("⚠️ Firestore save warning: \(error.localizedDescription)")
                    // Pokračujte i když Firestore selže - uživatel je registrovaný v Auth
                    // Můžete se pokusit znovu uložit později
                } else {
                    print("✅ Firestore save successful")
                }
                
                // Uživatel je přihlášen bez ohledu na Firestore výsledek
                self?.currentUserUID = uid
                self?.currentUserEmail = self?.email
                self?.isLoggedIn = true
                self?.isRegistered = true
                self?.errorMessage = ""
                
                print("🎉 Registration completed successfully")
            }
        }
    }
    
    private func updateLastLogin(uid: String) {
        let updateData: [String: Any] = [
            "lastLoggedIn": FieldValue.serverTimestamp(),
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
    // V AuthViewModel přidej do login a register funkcí:
    private func setupUserNotifications() {
        // Po přihlášení zkontroluj stav notifikací
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
