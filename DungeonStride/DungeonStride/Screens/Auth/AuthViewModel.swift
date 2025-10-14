//
//  AuthViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore


class AuthViewModel : ObservableObject {
    
    private let db = Firestore.firestore()
    
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    @Published var isRegistered = false
    @Published var isLoggedIn = false
    @Published var currentUserUID: String?
    
    func login(email: String, password: String) {
           
           isLoading = true
           errorMessage = ""
           Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
               DispatchQueue.main.async {
                   self?.isLoading = false
                   if let error = error {
                       self?.errorMessage = error.localizedDescription
                       return
                   }
                   
                   guard let user = result?.user else {
                       self?.errorMessage = "Login failed"
                       return
                   }
                   
                   //ReportLogger.log(.login, message: "User \(email) logged in")
               }
           }
       }
    
    
    private func updateFirebase(uid: String) {
           db.collection("users").document(uid).updateData(["lastLoggedIn": FieldValue.serverTimestamp()])
           self.fetchUserData(uid: uid)
       }
    
    
    func checkIfUserIsLoggedIn() {
           if let user = Auth.auth().currentUser {
               currentUserUID = user.uid
               print("Uživatel je stále přihlášen: \(user.email ?? "Neznámý email")")
           } else {
               isLoggedIn = false
               print("Uživatel není přihlášen")
           }
       }
    
    
    
    private func fetchUserData(uid: String) {
           db.collection("users").document(uid).getDocument { document, error in
               DispatchQueue.main.async {
                   self.isLoading = false
                   if let document = document, document.exists {
                       let data = document.data()
                   }
                   self.isLoggedIn = true
               }
           }
       }
    
    func register() {
           guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
               self.errorMessage = "Please fill in all fields"
               return
           }

           Auth.auth().createUser(withEmail: email, password: password) { result, error in
               DispatchQueue.main.async {
                   if let error = error {
                       self.errorMessage = "Registration error: \(error.localizedDescription)"
                   } else if let user = result?.user {
                       self.saveUserToFirestore(uid: user.uid)
                   } else {
                       self.errorMessage = "Failed to retrieve user information"
                   }
               }
           }
       }
    
    
    private func saveUserToFirestore(uid: String) {
            let userData: [String: Any] = [
                "username": username,
                "email": email,
                "imageUrl": "",
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]

            db.collection("users").document(uid).setData(userData) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Error saving to Firestore: \(error.localizedDescription)"
                    } else {
                        self.isRegistered = true
                        //ReportLogger.log(.registration, message: "New user registered: \(self.email)")

                    }
                }
            }
        }
    
    func logout() {
           do {
               if let email = Auth.auth().currentUser?.email {
                   //ReportLogger.log(.logout, message: "User \(email) logged out")
               }
               try Auth.auth().signOut()
               isLoggedIn = false
           } catch {
               errorMessage = error.localizedDescription
           }
       }
    
}
