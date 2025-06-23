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

class CartViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var items: [CartItem] = []
    @Published var note: String = ""
    @Published var selectedBranch: Cafe?
    @Published var branches: [Cafe] = []
    @Published var isSelectingBranchOnMap: Bool = false
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
        private var userLocation: CLLocationCoordinate2D?
    
    override init() {
            super.init()
            locationManager.delegate = self
            requestLocation()
            fetchBranches()
        }

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
                }
                completion(.success(()))
            }
        }
    }
    
    
    func setNearestBranchAsDefault() {
            guard let userLoc = userLocation else { return }
            self.selectedBranch = branches.min(by: {
                CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                    .distance(from: CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)) <
                CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                    .distance(from: CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude))
            })
        }
    
    func requestLocation() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first?.coordinate {
                userLocation = location
                setNearestBranchAsDefault()
                locationManager.stopUpdatingLocation()
            }
        }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location error: \(error.localizedDescription)")
        }

}

