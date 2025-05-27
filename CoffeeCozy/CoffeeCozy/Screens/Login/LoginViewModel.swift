//
//  LoginViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var showingRegistration = false
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Chyba při přihlášení: \(error.localizedDescription)"
                } else {
                    self.isLoggedIn = true
                }
            }
        }
    }
}
