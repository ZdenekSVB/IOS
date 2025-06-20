//
//  MapViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import SwiftUI
import CoreLocation
import MapKit

class MapViewModel: ObservableObject{
    var state: MapViewState = MapViewState()
    @Published var cafes: [Cafes] = []

        // Výchozí kamera na Brno
        @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        init() {
            loadCafes()
        }

        func loadCafes() {
            cafes = [
                Cafes(name: "Špilberk Castle", coordinates: CLLocationCoordinate2D(latitude: 49.1956, longitude: 16.6078)),
                Cafes(name: "St. Peter and Paul Cathedral", coordinates: CLLocationCoordinate2D(latitude: 49.1964, longitude: 16.6101)),
                Cafes(name: "Freedom Square", coordinates: CLLocationCoordinate2D(latitude: 49.1939, longitude: 16.6070))
            ]
        }
    
}
