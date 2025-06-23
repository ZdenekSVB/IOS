//
//  OrdersViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class OrdersViewModel: ObservableObject {
    @Published var orders: [OrderRecord] = []

    private var db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func fetchOrders() {
        guard let uid = userId else { return }

        db.collection("orders")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                do {
                    self.orders = try documents.map { try $0.data(as: OrderRecord.self) }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
    }
}
