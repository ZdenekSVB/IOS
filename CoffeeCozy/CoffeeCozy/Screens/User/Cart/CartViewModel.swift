//
//  CartViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

class CartViewModel: ObservableObject {
    
    @Published var items: [CartItem] = []
    @Published var isDelivery: Bool = false
    @Published var selectedBranch: String = ""
    @Published var paymentMethod: String = ""
    @Published var note: String = ""

    var totalPrice: Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.item.price) }
    }


    func add(item: SortimentItem) {
        if let index = items.firstIndex(where: { $0.item.id == item.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(item: item, quantity: 1))
        }
    }

    func increment(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].quantity += 1
    }

    func decrement(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }
    
    func submitOrder(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user logged in", code: 401)))
            return
        }

        let createdAt = Timestamp(date: Date())
        let finishedAt = Timestamp(date: Date())

        let orderItems = items.map { cartItem in
            return [
                "itemId": cartItem.item.id,
                "name": cartItem.item.name,
                "price": String(format: "%.0f", cartItem.item.price),
                "quantity": String(cartItem.quantity),
            ]
        }

        let orderData: [String: Any] = [
            "userId": userId,
            "createdAt": createdAt,
            "finishedAt": finishedAt,
            "totalPrice": totalPrice,
            "items": orderItems,
            "status": "pending"
        ]

        Firestore.firestore().collection("orders").addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    self.items.removeAll()
                }
                completion(.success(()))
            }
        }
    }

}

