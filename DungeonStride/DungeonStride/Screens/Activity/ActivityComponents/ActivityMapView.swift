//
//  ActivityMapView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI
import MapKit
import Charts
import CoreLocation

struct ActivityMapView: UIViewRepresentable {
    @Binding var polylineCoordinates: [CLLocationCoordinate2D]
    @Binding var region: MKCoordinateRegion?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let region = region {
            uiView.setRegion(region, animated: true)
        }
        
        if uiView.overlays.count > 0 {
            uiView.removeOverlays(uiView.overlays)
        }
        let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
        uiView.addOverlay(polyline)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ActivityMapView
        
        init(_ parent: ActivityMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
