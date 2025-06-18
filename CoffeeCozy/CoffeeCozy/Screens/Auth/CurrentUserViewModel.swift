//
//  CurrentUserViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class CurrentUserViewModel: ObservableObject {
    @Published var username: String = "Uživatel"

    init() {
        fetchUsername()
    }

    func fetchUsername() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let username = data["username"] as? String {
                DispatchQueue.main.async {
                    self.username = username
                }
            } else {
                print("Chyba při načítání username: \(error?.localizedDescription ?? "Neznámá chyba")")
            }
        }
    }
}
