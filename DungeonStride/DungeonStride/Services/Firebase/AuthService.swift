//
//  AuthService.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 22.01.2026.
//


//
//  AuthService.swift
//  DungeonStride
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import Combine

@MainActor
class AuthService: ObservableObject {
    
    @Published var user: FirebaseAuth.User?
    @Published var isLoggedIn: Bool = false
    
    // Závislost na UserService (pro vytváření profilu v DB)
    private var userService: UserService { DIContainer.shared.resolve() }
    
    init() {
        // Naslouchání změnám stavu přihlášení ve Firebase
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.user = user
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    // MARK: - Core Auth Actions
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        // Po přihlášení můžeme triggerovat načtení dat v UserService, pokud je to potřeba
        // Ale UserService má své listenery, takže to většinou není nutné.
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        // Vytvoření záznamu v databázi
        let _ = try await userService.createUser(uid: result.user.uid, email: email, username: username)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        // Lokální úklid
        userService.stopListeningForUserUpdates()
        userService.currentUser = nil
    }
    
    func updatePassword(oldPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Uživatel není přihlášen."])
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        try await user.reauthenticate(with: credential)
        try await user.updatePassword(to: newPassword)
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        // Smazat data z DB
        try await Firestore.firestore().collection("users").document(uid).delete()
        
        // Smazat Auth účet
        try await user.delete()
        
        // Sign out lokálně
        try signOut()
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async throws {
        guard (FirebaseApp.app()?.options.clientID) != nil else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        guard let idToken = signInResult.user.idToken?.tokenString else { return }
        
        let accessToken = signInResult.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // Handle Google User in Firestore
        let uid = authResult.user.uid
        let email = authResult.user.email ?? ""
        
        // Check if user exists, if not create
        do {
            let _ = try await userService.fetchUser(uid: uid)
            // User exists -> update last active
            try await userService.updateLastActive(uid: uid)
        } catch {
            // User does not exist -> create
            let googleUsername = authResult.user.displayName ?? email.components(separatedBy: "@").first ?? "GoogleUser"
            let _ = try await userService.createUser(uid: uid, email: email, username: googleUsername)
        }
    }
}