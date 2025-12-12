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
            // Použijeme Task, protože checkIfUserIsLoggedIn obsahuje asynchronní volání
            Task {
                await checkIfUserIsLoggedIn()
            }
        }
    }
    
    func setupThemeManager(_ themeManager: ThemeManager) {
        self.themeManager = themeManager
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
                    // handleSuccessfulLogin je non-async, ale spouští async Task.
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
                    // Oprava: Volání createUserInFirestore je async, vyžaduje await
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
            self.handleSuccessfulLogin(user: result.user) // Non-async volání handleSuccessfulLogin
            
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
            // Oprava: Zde musí být await, protože metody jsou async.
            await loadUserData(uid: user.uid)
            await assignDailyQuestsIfNeeded(for: user.uid)
            await updateLastLogin(uid: user.uid) // Oprava: updateLastLogin je async
        }
    }
    
    private func createUserInFirestore(uid: String) async {
        do {
            let _ = try await userService.createUser(uid: uid, email: email, username: username)
            isLoading = false
            // handleSuccessfulLogin je non-async, spouštíme ho na MainActoru.
            handleSuccessfulLogin(user: Auth.auth().currentUser!)
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            // Oprava: delete může selhat, musíme použít try
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
                // Oprava: updateLastActive je async, vyžaduje await
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
        // Oprava: Volání updateLastActive je async, vyžaduje await a try
        do {
            try await userService.updateLastActive(uid: uid)
        } catch {
            print("Failed to update last login: \(error.localizedDescription)")
        }
    }
    
    private func assignDailyQuestsIfNeeded(for uid: String) async {
        let userRef = db.collection("users").document(uid)
        
        do {
            let userDoc = try await userRef.getDocument()
            let lastDate = (userDoc.data()?["lastDailyQuestDate"] as? Timestamp)?.dateValue()
            let now = Date()
            
            if let lastDate = lastDate, Calendar.current.isDate(lastDate, inSameDayAs: now) {
                return
            }
            
            let allQuestsSnapshot = try await db.collection("quests").getDocuments()
            let allQuests = allQuestsSnapshot.documents.compactMap { $0.data() }
            
            guard allQuests.count >= 3 else { return }
            
            let shuffled = allQuests.shuffled().prefix(3)
            let dailyQuestsRef = userRef.collection("dailyQuests")
            
            let oldDocs = try await dailyQuestsRef.getDocuments()
            for doc in oldDocs.documents {
                try await dailyQuestsRef.document(doc.documentID).delete()
            }
            
            for var questData in shuffled {
                questData["isCompleted"] = false
                questData["progress"] = 0
                questData["assignedAt"] = FieldValue.serverTimestamp()
                
                let id = questData["id"] as? String ?? UUID().uuidString
                try await dailyQuestsRef.document(id).setData(questData)
            }
            
            try await userRef.updateData(["lastDailyQuestDate": FieldValue.serverTimestamp()])
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
