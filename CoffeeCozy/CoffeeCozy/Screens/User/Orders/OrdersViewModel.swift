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
    @Published var orders: [OrderItemA] = []

    private var db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        fetchOrders()
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

                self.orders = documents.compactMap { doc in
                    let data = doc.data()

                    let itemsData = data["items"] as? [[String: Any]] ?? []
                    let status = data["status"] as? String ?? "unknown"
                    let totalPrice = data["totalPrice"] as? Double ?? 0.0
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

                    let items: [OrderItemProduct] = itemsData.compactMap { itemDict in
                        guard
                            let name = itemDict["name"] as? String,
                            let quantityString = itemDict["quantity"] as? String,
                            let priceString = itemDict["price"] as? String,
                            let quantity = Int(quantityString),
                            let price = Double(priceString)
                        else {
                            print("Error fetched order contains a wrong data: \(itemDict)")
                            return nil
                        }

                        return OrderItemProduct(name: name, price: price, quantity: quantity )
                    }

                    return OrderItemA(items: items, status: status, totalPrice: totalPrice, createdAt: createdAt)
                }
            }
    }
}
