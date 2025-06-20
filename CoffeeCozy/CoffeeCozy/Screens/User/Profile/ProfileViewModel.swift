//
//  ProfileViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var username = ""
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var password = ""
    @Published var imageUrl = ""
    
    private let db = Firestore.firestore()
    private var userId: String? {
            Auth.auth().currentUser?.uid
        }
    private var updatedAt: Date?
    
    @Published var isLoading = false
    
    func loadUserData() {
            guard let uid = userId else { return }

            isLoading = true
            db.collection("users").document(uid).getDocument { document, error in
                self.isLoading = false
                if let error = error {
                    print("Chyba při načítání profilu: \(error.localizedDescription)")
                    return
                }

                guard let data = document?.data() else { return }

                self.username = data["username"] as? String ?? ""
                self.firstname = data["firstname"] as? String ?? ""
                self.lastname = data["lastname"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.imageUrl = data["imageUrl"] as? String ?? ""
            }
        }
    
    func save(){
        guard let uid = userId else { return }
        
        let userData: [String: Any] = [
            "username": username,
            "firstname": firstname,
            "lastname": lastname,
            "phoneNumber": phoneNumber,
            "email": email,
            "imageUrl": imageUrl,
            "updatedAt": Timestamp(date: Date()),
        ]
        
        db.collection("users").document(uid).updateData(userData) { error in
                    if let error = error {
                        print("Chyba při ukládání změn: \(error.localizedDescription)")
                    } else {
                        print("Uživatelský profil úspěšně aktualizován")
                    }
                }
    }
}
