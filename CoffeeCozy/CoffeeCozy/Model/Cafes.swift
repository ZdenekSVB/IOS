//
//  Cafes.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//
import UIKit
import CoreLocation

struct Cafes: Identifiable {
    var id = UUID()
    var name: String
    var coordinates: CLLocationCoordinate2D
    
}
