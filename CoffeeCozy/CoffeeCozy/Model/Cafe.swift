//
//  Cafes.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//
import UIKit
import CoreLocation

struct Cafe: Identifiable {
    var id: String              
    var name: String
    var description: String?
    var latitude: Double
    var longitude: Double
    var street: String?
    var buildingNumber: String?
    var city: String?
    var zipCode: String?

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
