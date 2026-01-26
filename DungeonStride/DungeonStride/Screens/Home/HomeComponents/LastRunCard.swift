//
//  LastRunCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct LastRunCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    let lastActivity: RunActivity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Last Activity", comment: "Title for last activity card")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                if let activity = lastActivity {
                    Text(activity.timeAgo) // Toto bude potřeba lokalizovat uvnitř modelu RunActivity (např. "2 days ago")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            if let activity = lastActivity {
                ZStack {
                    if let coords = activity.routeCoordinates, !coords.isEmpty {
                        ActivityMapView(
                            polylineCoordinates: .constant(coords),
                            region: .constant(calculateRegion(for: coords))
                        )
                        .frame(height: 150)
                        .cornerRadius(8)
                        .disabled(true)
                    } else {
                        Rectangle()
                            .fill(themeManager.secondaryTextColor.opacity(0.3))
                            .frame(height: 150)
                            .cornerRadius(8)
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeManager.accentColor)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Text(LocalizedStringKey(activity.type.capitalized)) // Lokalizace typu
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                .frame(height: 150)
                
                let units = userService.currentUser?.settings.units ?? .metric
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatItem(icon: "figure.walk", title: "Distance", value: units.formatDistance(Int(activity.distanceKm * 1000)))
                    StatItem(icon: "flame.fill", title: "Calories", value: "\(activity.calories)")
                    StatItem(icon: "timer", title: "Duration", value: activity.duration.stringFormat())
                    StatItem(icon: "speedometer", title: "Pace", value: formatPace(activity.pace, unit: units))
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("No activities yet", comment: "Empty state title")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("Go to Activity tab to start your first run!", comment: "Empty state subtitle")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func formatPace(_ paceMinKm: Double, unit: DistanceUnit) -> String {
        if unit == .metric {
            return String(format: "%.2f min/km", paceMinKm)
        } else {
            return String(format: "%.2f min/mi", paceMinKm * 1.60934)
        }
    }
    
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4)
        return MKCoordinateRegion(center: center, span: span)
    }
}
