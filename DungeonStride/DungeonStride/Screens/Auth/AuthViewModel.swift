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
    
    init() {
        self.db = Firestore.firestore()
        checkIfUserIsLoggedIn()
    }
    
    private func getDB() -> Firestore {
        guard let db = db else {
            fatalError("Firestore není inicializován")
        }
        return db
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Login error: \(error.localizedDescription)"
                    return
                }
                
                guard let user = result?.user else {
                    self?.errorMessage = "Login failed - no user data"
                    return
                }
                
                print("✅ User logged in: \(user.email ?? "Unknown")")
                self?.currentUserUID = user.uid
                self?.isLoggedIn = true
                self?.errorMessage = ""
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if let user = Auth.auth().currentUser {
            currentUserUID = user.uid
            isLoggedIn = true
            print("✅ User is already logged in: \(user.email ?? "Unknown email")")
        } else {
            isLoggedIn = false
            print("ℹ️ User is not logged in")
        }
    }
    
    func register() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill in all fields"
            return
        }
        
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = ""
        
        print("🔄 Starting registration for: \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = "Registration error: \(error.localizedDescription)"
                    print("❌ Registration failed: \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user else {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to retrieve user information"
                    print("❌ Registration failed - no user data")
                    return
                }
                
                print("✅ Firebase Auth success for: \(user.uid)")
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

        print("🔄 Saving user data to Firestore: \(uid)")
        
        getDB().collection("users").document(uid).setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Firestore error: \(error.localizedDescription)"
                    print("❌ Firestore save failed: \(error.localizedDescription)")
                    
                    // User je registrovaný v Auth, ale selhal zápis do Firestore
                    // Stále ho necháme přihlásit
                    self?.currentUserUID = uid
                    self?.isLoggedIn = true
                    self?.isRegistered = true
                    
                } else {
                    print("✅ User successfully saved to Firestore")
                    self?.currentUserUID = uid
                    self?.isLoggedIn = true
                    self?.isRegistered = true
                    self?.errorMessage = ""
                }
            }
        }
    }
    
    func logout() {
        do {
            if let email = Auth.auth().currentUser?.email {
                print("✅ User logged out: \(email)")
            }
            try Auth.auth().signOut()
            isLoggedIn = false
            isRegistered = false
            currentUserUID = nil
            email = ""
            password = ""
            username = ""
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Logout error: \(error.localizedDescription)")
        }
    }
}
