//
//  HistoryDetailView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 20.01.2026.
//


//
//  HistoryDetailView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
//

import SwiftUI
import MapKit

struct HistoryDetailView: View {
    let activity: RunActivity
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    // Vypočítáme region mapy, aby byla vidět celá trasa
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
        
        // Přidáme trochu místa okolo (buffer 1.5x)
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var body: some View {
        let units = userService.currentUser?.settings.units ?? .metric
        
        ZStack {
            // Pozadí
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 1. MAPA
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
                        // Fallback, pokud chybí GPS data
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
                    
                    // 2. STATISTIKY (GRID)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        DetailStatCard(
                            title: "Vzdálenost",
                            value: units.formatDistance(Int(activity.distanceKm * 1000)),
                            icon: "map.fill",
                            themeManager: themeManager
                        )
                        
                        DetailStatCard(
                            title: "Čas",
                            value: activity.duration.stringFormat(),
                            icon: "stopwatch.fill",
                            themeManager: themeManager
                        )
                        
                        DetailStatCard(
                            title: "Energie",
                            value: "\(activity.calories) kcal",
                            icon: "flame.fill",
                            themeManager: themeManager
                        )
                        
                        DetailStatCard(
                            title: "Tempo",
                            value: formatPace(activity.pace, unit: units),
                            icon: "speedometer",
                            themeManager: themeManager
                        )
                    }
                    
                    // 3. DATUM
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(themeManager.secondaryTextColor)
                        Text("Aktivita zaznamenána: \(activity.timestamp.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle(activity.type.capitalized) // Např. "Running"
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Pomocná funkce pro formátování tempa
    private func formatPace(_ paceMinKm: Double, unit: DistanceUnit) -> String {
        if unit == .metric {
            return String(format: "%.2f min/km", paceMinKm)
        } else {
            return String(format: "%.2f min/mi", paceMinKm * 1.60934)
        }
    }
}

// Pomocná komponenta pro kartičku se statistikou
struct DetailStatCard: View {
    let title: String
    let value: String
    let icon: String
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.accentColor)
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        // Jemný stín pro hloubku
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}