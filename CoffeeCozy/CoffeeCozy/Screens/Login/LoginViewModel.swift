//
//  LoginViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var showingRegistration = false
    
    private let db = Firestore.firestore()
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Chyba při přihlášení: \(error.localizedDescription)"
                } else if let user = result?.user{
                    self.updateFirebase(uid: user.uid)
                }
            }
        }
    }
    
    private func updateFirebase(uid: String){
        
        db.collection("users").document(uid).updateData(["lastLoggedIn": FieldValue.serverTimestamp()])
        self.isLoggedIn = true
    }
}
