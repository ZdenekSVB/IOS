//
//  ActivityMapCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct ActivityMapCard: View {
    let activity: RunActivity
    @EnvironmentObject var themeManager: ThemeManager
    
    private var region: MKCoordinateRegion {
        guard let coords = activity.routeCoordinates, !coords.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
        
        let lats = coords.map { $0.latitude }
        let lons = coords.map { $0.longitude }
        
        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var body: some View {
        if let coords = activity.routeCoordinates, !coords.isEmpty {
            
            ActivityMapView(
                polylineCoordinates: .constant(coords),
                region: .constant(region)
            )
            .frame(height: 300)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
            )
        } else {
            fallbackView
        }
    }
    
    private var fallbackView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackgroundColor)
                .frame(height: 200)
            VStack {
                Image(systemName: "location.slash.fill")
                    .font(.largeTitle)
                    .foregroundColor(themeManager.secondaryTextColor)
                Text("Žádná GPS data")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
    }
}
