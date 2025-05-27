//
//  LocationManager.swift
//  CityGuide
//
//  Created by David Procházka on 02.04.2025.
//
import MapKit
import SwiftUI
import CoreLocation

@Observable
final class LocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var currentCity: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    var cameraPosition: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(
                latitude: 49.21044343932761,
                longitude: 16.6157301199077
            ),
            distance: 3000
        )
    )
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let actLocation = locations.last {
            let coords = actLocation.coordinate
            cameraPosition = .camera(
                .init(
                    centerCoordinate: .init(
                        latitude: coords.latitude,
                        longitude: coords.longitude
                    ),
                    distance: 3000
                )
            )
            getCurrentCityName(from: coords) { city in
                self.currentCity = city
            }
            currentLocation = coords
        }
    }
    
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double? {
        if let actLocation = currentLocation {
            let fromLocation: CLLocation = .init(
                latitude: actLocation.latitude,
                longitude: actLocation.longitude
            )
            
            let toLocation: CLLocation = .init(
                latitude: to.latitude,
                longitude: to.longitude
            )
            
            return fromLocation.distance(from: toLocation)
        } else {
            return nil
        }
    }
    
    func getCurrentCityName(from coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Cannot geocode: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let placemark = placemarks?.first {
                let city = placemark.locality ??
                           placemark.subAdministrativeArea ??
                           placemark.administrativeArea

                completion(city)
            } else {
                completion(nil)
            }
        }
    }
}
