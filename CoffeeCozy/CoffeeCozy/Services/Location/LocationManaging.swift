
import MapKit
import SwiftUI

protocol LocationManaging {
    var cameraPosition: MapCameraPosition { get }
    var currentLocation: CLLocationCoordinate2D? { get }
    var currentCity: String? { get }
    
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double?
}
