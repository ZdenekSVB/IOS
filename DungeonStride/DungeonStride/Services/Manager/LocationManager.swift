//
//  LocationManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 21.01.2026.
//


//
//  LocationManager.swift
//  DungeonStride
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // Publikujeme polohu a chyby, aby je ActivityManager mohl "odebírat"
    @Published var lastLocation: CLLocation?
    @Published var locationError: String?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .fitness
        
        // Okamžitá kontrola oprávnění
        self.authStatus = manager.authorizationStatus
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func stopTracking() {
        manager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Filtrace nepřesných dat (přeneseno z původního kódu)
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 50 {
            return
        }
        
        self.lastLocation = newLocation
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .denied, .restricted:
            locationError = "Please enable location access in settings."
        default:
            locationError = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
        // Můžeme sem přidat logiku pro nastavení locationError, pokud je to kritické
    }
}