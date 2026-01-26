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
    
    private var userService: UserService { DIContainer.shared.resolve() }
    
    init() {
        // OPRAVA: Přiřazení listeneru do '_', aby Xcode nekřičel
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.user = user
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        // OPRAVA: discard result
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        // Zde je result použit, takže OK
        _ = try await userService.createUser(uid: result.user.uid, email: email, username: username)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
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
        
        try await Firestore.firestore().collection("users").document(uid).delete()
        try await user.delete()
        try signOut()
    }
    
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
        
        let uid = authResult.user.uid
        let email = authResult.user.email ?? ""
        
        do {
            _ = try await userService.fetchUser(uid: uid)
            try await userService.updateLastActive(uid: uid)
        } catch {
            let googleUsername = authResult.user.displayName ?? email.components(separatedBy: "@").first ?? "GoogleUser"
            _ = try await userService.createUser(uid: uid, email: email, username: googleUsername)
        }
    }
}
