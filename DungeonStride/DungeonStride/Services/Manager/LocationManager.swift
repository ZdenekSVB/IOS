//
//  LocationManager.swift
//  DungeonStride
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var lastLocation: CLLocation?
    @Published var locationError: String?
    @Published var authStatus: CLAuthorizationStatus
    
    private let manager = CLLocationManager()
    
    override init() {
        self.authStatus = manager.authorizationStatus // Inicializace před super.init není u manageru možná, takže takto:
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .fitness
        
        // Aktualizace statusu po nastavení delegáta
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
    
    // MARK: - Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Filtrace nepřesné GPS ( > 50m nebo nevalidní < 0)
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
        print("Location Manager Error: \(error.localizedDescription)")
    }
}
