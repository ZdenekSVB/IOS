//
//  AEditUserViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AEditUserViewModel: ObservableObject {
    @Published var username = ""
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var password = ""
    @Published var imageUrl = ""
    @Published var role = "user"

    private let db = Firestore.firestore()
    private var existingUserId: String?
    private var createdAt: Date?

    var isEditing: Bool { existingUserId != nil }

    init(user: User? = nil) {
        if let user = user {
            username = user.username
            firstname = user.firstname
            lastname = user.lastname
            phoneNumber = user.phoneNumber
            email = user.email
            imageUrl = user.imageUrl ?? ""
            role = user.role
            existingUserId = user.id
            createdAt = user.createdAt
        }
    }

    var isValid: Bool {
        !username.isEmpty && !firstname.isEmpty && !lastname.isEmpty && !email.isEmpty && (isEditing || !password.isEmpty)
    }

    func save() {
        let now = Date()
        let userData: [String: Any] = [
            "username": username,
            "firstname": firstname,
            "lastname": lastname,
            "phoneNumber": phoneNumber,
            "email": email,
            "imageUrl": imageUrl,
            "role": role,
            "updatedAt": Timestamp(date: now),
            "createdAt": Timestamp(date: createdAt ?? now)
        ]

        if let id = existingUserId {
            db.collection("users").document(id).setData(userData, merge: true) { error in
                if let error = error {
                    print("Chyba při aktualizaci uživatele: \(error.localizedDescription)")
                } else {
                    ReportLogger.log(.nameChange, message: "User updated: \(self.username) – ID: \(id)")
                    print("Uživatel aktualizován")
                }
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Chyba při registraci uživatele v Auth: \(error.localizedDescription)")
                    return
                }

                guard let uid = result?.user.uid else { return }

                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        print("Chyba při ukládání do Firestore: \(error.localizedDescription)")
                    } else {
                        print("Nový uživatel úspěšně vytvořen")
                    }
                }
            }
        }
    }
}
