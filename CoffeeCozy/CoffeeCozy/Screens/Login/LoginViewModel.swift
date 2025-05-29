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
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var isAdmin = false
    
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
        self.fetchUserData(uid: uid)
    }
    
    private func fetchUserData(uid: String){
        
        db.collection("users").document(uid).getDocument{ document, error in
            DispatchQueue.main.async{
                if let document = document, document.exists {
                    let data = document.data()
                    if let role = data?["role"] as? String{
                        self.isAdmin = (role == "admin")
                    } else{
                        self.isAdmin = false
                    }
                }
            }
        }
    }
}
