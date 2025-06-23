//
//  CLLocationCoordinate2D+Extension.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 23.06.2025.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
