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
    
    // ZMĚNA: Už nevytváříme novou instanci, ale čekáme na tu sdílenou
    var userService: UserService?
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
    
    // ZMĚNA: Init je prázdný, logika se spouští až v 'setup'
    init() {}
    
    // ZMĚNA: Jedna metoda pro nastavení všech závislostí a spuštění kontroly přihlášení
    func setup(userService: UserService, questService: QuestService, themeManager: ThemeManager) {
        self.userService = userService
        self.questService = questService
        self.themeManager = themeManager
        
        // Spustíme kontrolu až teď, když máme UserService k dispozici
        if Auth.auth().currentUser != nil {
            Task {
                await checkIfUserIsLoggedIn()
            }
        }
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
        guard (FirebaseApp.app()?.options.clientID) != nil else { return }
        
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
            
            // Vyčistíme data v UserService a přestaneme naslouchat
            userService?.currentUser = nil
            userService?.stopListeningForUserUpdates()
            
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
            // 1. Spustit naslouchání na User profil (to zajistí, že UI se hned aktualizuje)
            // ZMĚNA: Používáme startListening místo jednorázového fetch
            userService?.startListeningForUserUpdates(uid: user.uid)
            
            // 2. Počkáme chvilku, než se načte user, abychom mohli zkontrolovat nastavení (dark mode)
            // Poznámka: startListening je asynchronní, data přijdou do UserService sama.
            // Pro jistotu zde načteme Theme explicitně, pokud už data máme.
            if let fetchedUser = try? await userService?.fetchUser(uid: user.uid) {
                themeManager?.setDarkMode(fetchedUser.settings.isDarkMode)
                
                // 3. Zkontrolovat reset dne
                // Protože startListening už běží, checkAndResetDailyStats by měl pracovat s aktuálními daty
                // nebo si je stáhne znovu.
                let isNewDay = (try? await userService?.checkAndResetDailyStats(userId: user.uid)) ?? false
                
                // 4. Spravovat Questy
                if isNewDay {
                    try? await questService?.regenerateDailyQuests(for: user.uid)
                } else {
                    try? await questService?.loadDailyQuests(for: user.uid)
                }
            }
            
            // 5. Update Last Active
            await updateLastLogin(uid: user.uid)
        }
    }
    
    private func createUserInFirestore(uid: String) async {
        do {
            let _ = try await userService?.createUser(uid: uid, email: email, username: username)
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
            let existingUser = try? await userService?.fetchUser(uid: user.uid)
            
            if existingUser == nil {
                let googleUsername = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "GoogleUser"
                let _ = try await userService?.createUser(uid: user.uid, email: user.email ?? "", username: googleUsername)
            } else {
                let isNewDay = (try? await userService?.checkAndResetDailyStats(userId: user.uid)) ?? false
                if isNewDay {
                    try? await questService?.regenerateDailyQuests(for: user.uid)
                }
                try await userService?.updateLastActive(uid: user.uid)
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func checkIfUserIsLoggedIn() async {
        if let user = Auth.auth().currentUser {
            handleSuccessfulLogin(user: user)
        }
    }
    
    private func updateLastLogin(uid: String) async {
        do {
            try await userService?.updateLastActive(uid: uid)
        } catch {
            print("Failed to update last login: \(error.localizedDescription)")
        }
    }
}
