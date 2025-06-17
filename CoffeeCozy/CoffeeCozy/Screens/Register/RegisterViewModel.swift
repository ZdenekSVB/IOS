//
//  RegisterViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var isRegistered = false
    @Published var errorMessage = ""
    @Published var showingLogin = false

    private let db = Firestore.firestore()

    func register() {
        guard !username.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !phone.isEmpty, !password.isEmpty else {
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
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phoneNumber": phone,
            "role": "user",
            "avatar": "default",
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoggedIn": FieldValue.serverTimestamp()
        ]

        db.collection("users").document(uid).setData(userData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error saving to Firestore: \(error.localizedDescription)"
                } else {
                    self.isRegistered = true
                }
            }
        }
    }
}
