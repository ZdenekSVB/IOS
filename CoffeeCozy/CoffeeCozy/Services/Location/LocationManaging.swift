//
//  LocationManaging.swift
//  CityGuide
//
//  Created by David Procházka on 02.04.2025.
//
import MapKit
import SwiftUI

protocol LocationManaging {
    var cameraPosition: MapCameraPosition { get }
    var currentLocation: CLLocationCoordinate2D? { get }
    var currentCity: String? { get }
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double?
}
