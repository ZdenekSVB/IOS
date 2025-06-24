//
//  MapViewState.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import Observation
import MapKit
import SwiftUI

@Observable
final class MapViewState {

    var cafes: [Cafe] = []

    var selectedCafe: Cafe?

    var currentLocation: CLLocationCoordinate2D?

    var mapCameraPosition: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(
                latitude: 49.21044343932761,
                longitude: 16.6157301199077
            ),
            distance: 3000
        )
    )
}
