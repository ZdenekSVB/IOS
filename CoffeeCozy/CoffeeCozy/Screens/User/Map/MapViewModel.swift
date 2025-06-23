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

@Observable
class MapViewModel: ObservableObject {
    var state: MapViewState = MapViewState()

    private var db = Firestore.firestore()
    private var locationManager: LocationManaging
    private var periodicUpdatesRunning = false
    
    init() {
        locationManager = DIContainer.shared.resolve()
    }
}

extension MapViewModel{
    
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
                self.state.cafes = loadedCafes
            }
        }
    }
    
    func syncLocation() {
        state.mapCameraPosition = locationManager.cameraPosition
        state.currentLocation = locationManager.currentLocation
    }
    
    func findNearestCafe(to location: CLLocationCoordinate2D) -> Cafe? {
        state.cafes.min { cafeA, cafeB in
            let locA = CLLocation(latitude: cafeA.latitude, longitude: cafeA.longitude)
            let locB = CLLocation(latitude: cafeB.latitude, longitude: cafeB.longitude)
            let userLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            return locA.distance(from: userLoc) < locB.distance(from: userLoc)
        }
    }
    
    func startPeriodicLocationUpdate() async {
        if !periodicUpdatesRunning {
            periodicUpdatesRunning.toggle()
            
            while true {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                syncLocation()
            }
        }
    }
}

