//
//  ActivityComponents.swift
//  DungeonStride
//

import SwiftUI
import MapKit
import Charts
import CoreLocation

// MARK: - Terrain Toggle Button
struct TerrainToggleButton: View {
    let isNautical: Bool
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isNautical ? "sailboat.fill" : "figure.run")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 32)
                .background(isNautical ? Color.blue : Color.green)
                .cornerRadius(8)
        }
    }
}

// MARK: - Map View
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

// MARK: - Charts
struct PaceChart: View {
    @ObservedObject var activityManager: ActivityManager
    let themeManager: ThemeManager
    let units: DistanceUnit
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Speed (\(units.speedSymbol))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            if activityManager.rawSpeedHistory.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                        .frame(height: 120)
                    Text("Start activity to see data")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            } else {
                Chart {
                    ForEach(Array(activityManager.rawSpeedHistory.enumerated()), id: \.offset) { index, speedMs in
                        // Převedeme m/s na km/h (nebo mph/uzly) přímo v grafu
                        let convertedSpeed = units.convertSpeed(fromMetersPerSecond: speedMs)
                        
                        LineMark(
                            x: .value("Segment", index + 1),
                            y: .value("Speed", convertedSpeed)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.accentColor.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYAxisLabel(units.speedSymbol)
                .chartYScale(domain: .automatic(includesZero: false))
            }
        }
    }
}

// MARK: - Metrics Grid
struct MetricsView: View {
    @ObservedObject var activityManager: ActivityManager
    let themeManager: ThemeManager
    let units: DistanceUnit
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
            MetricItem(
                title: "Duration",
                value: activityManager.elapsedTime.stringFormat(),
                themeManager: themeManager
            )
            
            MetricItem(
                title: "Distance",
                value: units.formatDistance(Int(activityManager.distance)),
                themeManager: themeManager
            )
            
            MetricItem(
                title: "Speed",
                // Zde se používá formátovač z DistanceUnit, který to hodí do km/h, mph nebo uzlů
                value: units.formatSpeed(metersPerSecond: activityManager.currentSpeed),
                themeManager: themeManager
            )
            
            MetricItem(
                title: "Energy",
                value: String(format: "%.0f kcal", activityManager.kcalBurned),
                themeManager: themeManager
            )
        }
    }
}

// MARK: - Metric Item Component
struct MetricItem: View {
    let title: String
    let value: String
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(themeManager.primaryTextColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Control Buttons
struct ActivityActionButtons: View {
    @ObservedObject var activityManager: ActivityManager
    var authViewModel: AuthViewModel
    var userService: UserService
    @EnvironmentObject var questService: QuestService
    
    var body: some View {
        HStack(spacing: 20) {
            // START / PAUSE
            Button {
                if activityManager.activityState == .active {
                    
                    activityManager.pauseActivity()
                } else {
                    activityManager.startActivity()
                }
            } label: {
                Image(systemName: activityManager.activityState == .active ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(activityManager.activityState == .active ? Color.orange : Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            
            // STOP
            if activityManager.activityState == .active || activityManager.activityState == .paused {
                Button {
                    activityManager.finishActivity(
                        userId: authViewModel.currentUserUID,
                        userService: userService,
                        questService: questService
                    )
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // RESET
            if activityManager.activityState == .finished {
                Button {
                    activityManager.resetActivity()
                } label: {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: activityManager.activityState)
    }
}

// MARK: - Overlay
struct ErrorOverlay: View {
    let message: String
    var body: some View {
        VStack {
            Spacer()
            Text("⚠️ \(message)")
                .padding()
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 50)
        }
        .transition(.move(edge: .bottom))
        .zIndex(2)
    }
}
