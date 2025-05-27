//
//  RegisterViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//
import Foundation
import FirebaseAuth

class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var isRegistered = false
    @Published var errorMessage = ""
    @Published var showingLogin = false
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Chyba při registraci: \(error.localizedDescription)"
                } else {
                    // Save firstName, lastName, phone to Firestore (if needed)
                    self.isRegistered = true
                }
            }
        }
    }
}
