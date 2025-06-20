//
//  MapViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import SwiftUI
import CoreLocation
import MapKit
import FirebaseFirestore

class MapViewModel: ObservableObject{
    var state: MapViewState = MapViewState()
    @Published var cafes: [Cafe] = []

    private var db = Firestore.firestore()

    init() {
        fetchCafes()
    }

    func fetchCafes() {
        db.collection("locations").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching cafes: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            let loadedCafes = documents.compactMap { doc -> Cafe? in
                let data = doc.data()

                guard
                    let name = data["name"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                else {
                    return nil
                }

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
                self.cafes = loadedCafes
            }
        }
    }


    
    
    
}
