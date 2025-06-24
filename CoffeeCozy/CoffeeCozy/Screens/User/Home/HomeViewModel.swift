//
//  HomeViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import Combine

class HomeViewModel: ObservableObject {
    @Published var totalPriceText: String = ""
    @Published var rewardPoints: Int = 0
    @Published var message: String = ""
    @Published var isLoading = false
    @Published var profileImageUrl: String? = nil
    
    @Published var latestOrder: OrderRecord? = nil

    private var db = Firestore.firestore()

    var currentUserUID: String? {
        Auth.auth().currentUser?.uid
    }

    func fetchRewardPoints() {
        guard let uid = currentUserUID else { return }
        isLoading = true

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = snapshot?.data() {
                    self?.rewardPoints = data["rewardPoints"] as? Int ?? 0
                    self?.profileImageUrl = data["imageUrl"] as? String
                }
            }
        }
    }

    func calculatePoints() -> Int {
        guard let price = Double(totalPriceText) else { return 0 }
        return Int(price / 10)
    }

    func savePoints() {
        guard let uid = currentUserUID else {
            message = "Uživatel není přihlášen."
            return
        }

        let newPoints = calculatePoints()
        guard newPoints > 0 else {
            message = "Zadejte cenu alespoň 10 USD pro získání bodů."
            return
        }

        isLoading = true
        let userRef = db.collection("users").document(uid)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let currentPoints = userDocument.data()?["rewardPoints"] as? Int ?? 0
            let updatedPoints = currentPoints + newPoints

            transaction.updateData(["rewardPoints": updatedPoints], forDocument: userRef)
            return updatedPoints
        } completion: { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.message = "Chyba při ukládání bodů: \(error.localizedDescription)"
                } else if let updatedPoints = result as? Int {
                    self?.rewardPoints = updatedPoints
                    self?.message = "Uloženo! Máte nyní \(updatedPoints) bodů."
                }
            }
        }
    }
    
    func claimFreeCoffee() {
        guard let uid = currentUserUID else {
            message = "Uživatel není přihlášen."
            return
        }
        guard rewardPoints >= 10 else {
            message = "Nemáte dostatek bodů pro claim."
            return
        }

        isLoading = true
        let userRef = db.collection("users").document(uid)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let currentPoints = userDocument.data()?["rewardPoints"] as? Int ?? 0
            if currentPoints < 10 {
                errorPointer?.pointee = NSError(domain: "InsufficientPoints", code: 0, userInfo: [NSLocalizedDescriptionKey: "Nedostatek bodů"])
                return nil
            }
            let updatedPoints = currentPoints - 10
            transaction.updateData(["rewardPoints": updatedPoints], forDocument: userRef)
            return updatedPoints
        } completion: { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.message = "Chyba při claimu: \(error.localizedDescription)"
                } else if let updatedPoints = result as? Int {
                    self?.rewardPoints = updatedPoints
                    self?.message = "Claim successful! Zbývá vám \(updatedPoints) bodů."
                }
            }
        }
    }
    
    func fetchLatestOrder() {
        guard let uid = currentUserUID else { return }

        db.collection("orders")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let document = snapshot?.documents.first else {
                    DispatchQueue.main.async {
                        self?.latestOrder = nil
                    }
                    return
                }
                do {
                    let order = try document.data(as: OrderRecord.self)
                    DispatchQueue.main.async {
                        self?.latestOrder = order
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
    }
}
