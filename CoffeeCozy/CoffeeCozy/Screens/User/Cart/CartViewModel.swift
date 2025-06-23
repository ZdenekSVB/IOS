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
import CoreLocation

class CartViewModel: ObservableObject {
    
    @Published var items: [CartItem] = []
    @Published var note: String = ""
    @Published var selectedBranch: Cafe?
    @Published var branches: [Cafe] = []
    @Published var isSelectingBranchOnMap: Bool = false
    
    @Published var userPoints: Int = 0
    @Published var freeCoffeeRedemptions: [UUID: Int] = [:]
    
    var redeemableCount: Int {
        userPoints / 10
    }
    
    var redeemedFreeCoffees: Int {
        freeCoffeeRedemptions.values.reduce(0, +)
    }
    
    private let db = Firestore.firestore()
    let locationManager: LocationManaging
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        fetchBranches()
        fetchUserPoints()
    }
    
    var totalPrice: Double {
        var price = 0.0
        for item in items {
            let redeemedCount = freeCoffeeRedemptions[item.id] ?? 0
            let paidQuantity = max(0, item.quantity - redeemedCount)
            price += Double(paidQuantity) * item.item.price
        }
        return price
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
    
    func fetchBranches() {
        db.collection("locations").getDocuments { snapshot, error in
            if let error = error {
                print("Fetching branches failed: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let cafes: [Cafe] = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let name = data["name"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                else { return nil }
                
                return Cafe(
                    id: doc.documentID,
                    name: name,
                    description: data["description"] as? String,
                    latitude: latitude,
                    longitude: longitude,
                    street: data["street"] as? String,
                    buildingNumber: data["buildingNumber"] as? String,
                    city: data["city"] as? String,
                    zipCode: data["zipCode"] as? String
                )
            }
            
            DispatchQueue.main.async {
                self.branches = cafes
            }
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
            let freeCount = freeCoffeeRedemptions[cartItem.id] ?? 0
            return [
                "itemId": cartItem.item.id,
                "name": cartItem.item.name,
                "price": String(format: "%.0f", cartItem.item.price),
                "quantity": String(cartItem.quantity),
            ]
        }
        
        let branchData: [String: Any] = [
            "name": selectedBranch?.name ?? "",
            "street": selectedBranch?.street ?? "",
            "buildingNumber": selectedBranch?.buildingNumber ?? "",
            "city": selectedBranch?.city ?? "",
            "zipCode": selectedBranch?.zipCode ?? "",
            "latitude": selectedBranch?.latitude ?? 0.0,
            "longitude": selectedBranch?.longitude ?? 0.0
        ]
        
        let orderData: [String: Any] = [
            "userId": userId,
            "createdAt": createdAt,
            "finishedAt": finishedAt,
            "totalPrice": totalPrice,
            "items": orderItems,
            "status": "pending",
            "branch": branchData
        ]
        
        db.collection("orders").addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    self.items.removeAll()
                    self.freeCoffeeRedemptions.removeAll()
                }
                
                let totalRedeemed = self.freeCoffeeRedemptions.values.reduce(0, +)
                self.db.collection("users").document(userId).updateData([
                    "rewardPoints": FieldValue.increment(Int64(-10 * totalRedeemed))
                ]) { _ in
                    self.fetchUserPoints()
                }
                
                
                let pointsToAdd = Int(self.totalPrice) / 10
                self.db.collection("users").document(userId).updateData([
                    "rewardPoints": FieldValue.increment(Int64(pointsToAdd))
                ]) { _ in
                    self.fetchUserPoints()
                }
                
                completion(.success(()))
            }
        }
    }
    
    func fetchUserPoints() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let points = data["rewardPoints"] as? Int {
                DispatchQueue.main.async {
                    self.userPoints = points
                }
            }
        }
    }
    
    func redeemFreeCoffee(for cartItem: CartItem) {
        let currentRedeemed = freeCoffeeRedemptions[cartItem.id] ?? 0
        
        guard redeemedFreeCoffees < redeemableCount else { return } // limit bodů
        guard currentRedeemed < cartItem.quantity else { return }  // nemůžeš redeemovat víc než kusů
        
        freeCoffeeRedemptions[cartItem.id] = currentRedeemed + 1
    }
    
    
    func removeRedeemedFreeCoffee(for cartItem: CartItem) {
        let currentRedeemed = freeCoffeeRedemptions[cartItem.id] ?? 0
        if currentRedeemed > 0 {
            freeCoffeeRedemptions[cartItem.id] = currentRedeemed - 1
            if freeCoffeeRedemptions[cartItem.id] == 0 {
                freeCoffeeRedemptions.removeValue(forKey: cartItem.id)
            }
        }
    }
    
    func syncFreeCoffeeRedemptions() {
        for (itemId, redeemedCount) in freeCoffeeRedemptions {
            guard let item = items.first(where: { $0.id == itemId }) else {
                // Položka už neexistuje, smažeme všechny free coffee pro ni
                freeCoffeeRedemptions.removeValue(forKey: itemId)
                continue
            }
            if redeemedCount > item.quantity {
                freeCoffeeRedemptions[itemId] = item.quantity
            }
        }
    }
    
}

