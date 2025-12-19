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
    
    private let db = Firestore.firestore()
    private let userService = UserService()
    private var questService: QuestService?
    private var themeManager: ThemeManager?
    
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    @Published var currentUserUID: String?
    @Published var currentUserEmail: String?
    
    init() {
        if Auth.auth().currentUser != nil {
            Task {
                await checkIfUserIsLoggedIn()
            }
        }
    }
    
    func setupThemeManager(_ themeManager: ThemeManager) {
        self.themeManager = themeManager
    }
    
    func setupQuestService(_ questService: QuestService) {
        self.questService = questService
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let user = result?.user {
                    self.handleSuccessfulLogin(user: user)
                }
            }
        }
    }
    
    func register() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let user = result?.user {
                    await self.createUserInFirestore(uid: user.uid)
                }
            }
        }
    }
    
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                isLoading = false
                return
            }
            
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let idToken = signInResult.user.idToken?.tokenString else {
                isLoading = false
                return
            }
            
            let accessToken = signInResult.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let result = try await Auth.auth().signIn(with: credential)
            
            await handleGoogleUser(user: result.user)
            self.handleSuccessfulLogin(user: result.user)
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            currentUserUID = nil
            currentUserEmail = nil
            email = ""
            password = ""
            username = ""
            errorMessage = ""
            userService.currentUser = nil
            themeManager?.setDarkMode(false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func handleSuccessfulLogin(user: FirebaseAuth.User) {
        currentUserUID = user.uid
        currentUserEmail = user.email
        isLoggedIn = true
        errorMessage = ""
        
        Task {
            // 1. Načíst data uživatele
            await loadUserData(uid: user.uid)
            
            // 2. Zkontrolovat reset dne (vrací Bool)
            let isNewDay = (try? await userService.checkAndResetDailyStats(userId: user.uid)) ?? false
            
            // 3. Spravovat Questy
            if isNewDay {
                // Je nový den -> SMAZAT staré a STÁHNOUT nové šablony z DB
                try? await questService?.regenerateDailyQuests(for: user.uid)
            } else {
                // Stejný den -> Jen načíst existující (nebo stáhnout, pokud chybí)
                try? await questService?.loadDailyQuests(for: user.uid)
            }
            
            // 4. Update Last Active
            await updateLastLogin(uid: user.uid)
        }
    }
    
    private func createUserInFirestore(uid: String) async {
        do {
            let _ = try await userService.createUser(uid: uid, email: email, username: username)
            isLoading = false
            if let user = Auth.auth().currentUser {
                handleSuccessfulLogin(user: user)
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            try? await Auth.auth().currentUser?.delete()
        }
    }
    
    private func handleGoogleUser(user: FirebaseAuth.User) async {
        do {
            let existingUser = try? await userService.fetchUser(uid: user.uid)
            
            if existingUser == nil {
                let googleUsername = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "GoogleUser"
                let _ = try await userService.createUser(uid: user.uid, email: user.email ?? "", username: googleUsername)
            } else {
                let isNewDay = (try? await userService.checkAndResetDailyStats(userId: user.uid)) ?? false
                if isNewDay {
                    try? await questService?.regenerateDailyQuests(for: user.uid)
                }
                try await userService.updateLastActive(uid: user.uid)
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadUserData(uid: String) async {
        do {
            let user = try await userService.fetchUser(uid: uid)
            await MainActor.run {
                themeManager?.setDarkMode(user.settings.isDarkMode)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func checkIfUserIsLoggedIn() async {
        if let user = Auth.auth().currentUser {
            handleSuccessfulLogin(user: user)
        }
    }
    
    private func updateLastLogin(uid: String) async {
        do {
            try await userService.updateLastActive(uid: uid)
        } catch {
            print("Failed to update last login: \(error.localizedDescription)")
        }
    }
}
