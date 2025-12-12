//
//  ActivityComponents.swift
//  DungeonStride
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
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let region = region {
            uiView.setRegion(region, animated: true)
        }
        
        uiView.removeOverlays(uiView.overlays)
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
                renderer.strokeColor = .red
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct PaceChart: View {
    @ObservedObject var activityManager: ActivityManager
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tempo (min/km)")
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)
            
            Chart {
                ForEach(Array(activityManager.paceHistoryForChart.enumerated()), id: \.offset) { index, paceInMinPerKm in
                    if paceInMinPerKm > 0 {
                        LineMark(
                            x: .value("Segment", index + 1),
                            y: .value("Tempo", paceInMinPerKm)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color.yellow)
                    }
                }
            }
            .chartYAxisLabel("min/km")
            .chartXAxisLabel("Úsek")
            .chartYScale(domain: .automatic(includesZero: false))
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(10)
    }
}

struct MetricsView: View {
    @ObservedObject var activityManager: ActivityManager
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                MetricItem(title: "Čas", value: activityManager.elapsedTime.stringFormat(), themeManager: themeManager)
                Spacer()
                MetricItem(title: "Vzdálenost", value: String(format: "%.2f km", activityManager.distance / 1000.0), themeManager: themeManager)
            }
            HStack {
                MetricItem(title: "Tempo", value: activityManager.pace, themeManager: themeManager)
                Spacer()
                MetricItem(title: "Kcal", value: String(format: "%.0f kcal", activityManager.kcalBurned), themeManager: themeManager)
            }
        }
        .padding(.horizontal)
    }
}

struct ActivityActionButtons: View {
    @ObservedObject var activityManager: ActivityManager
    var authViewModel: AuthViewModel
    var userService: UserService
    
    var body: some View {
        HStack(spacing: 30) {
            Button {
                if activityManager.activityState == .active {
                    activityManager.pauseActivity()
                } else {
                    activityManager.startActivity()
                }
            } label: {
                Text(activityManager.activityState == .active ? "PAUZA" : (activityManager.activityState == .paused ? "POKRAČOVAT" : "START"))
                    .buttonStyle(state: activityManager.activityState == .active ? .pause : .start)
            }
            
            if activityManager.activityState == .active || activityManager.activityState == .paused {
                Button {
                    activityManager.finishActivity(
                        userId: authViewModel.currentUserUID,
                        userService: userService
                    )
                } label: {
                    Text("STOP")
                        .buttonStyle(state: .stop)
                }
            }
            
            if activityManager.activityState == .finished {
                Button {
                    activityManager.resetActivity()
                } label: {
                    Text("RESET")
                        .buttonStyle(state: .stop)
                }
            }
        }
    }
}

struct MetricItem: View {
    let title: String
    let value: String
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
        }
    }
}

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
    }
}

enum ActivityButtonState {
    case start, pause, stop
}

struct ActivityButtonStyle: ViewModifier {
    let state: ActivityButtonState
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(width: 100, height: 100)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(Circle())
            .overlay(Circle().stroke(lineWidth: 3).foregroundColor(foregroundColor))
    }
    
    var backgroundColor: Color {
        switch state {
        case .start: return .green
        case .pause: return .orange
        case .stop: return .red
        }
    }
    
    var foregroundColor: Color {
        switch state {
        case .start, .pause, .stop: return .white
        }
    }
}

extension View {
    func buttonStyle(state: ActivityButtonState) -> some View {
        modifier(ActivityButtonStyle(state: state))
    }
}
extension TimeInterval {
    func stringFormat() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "00:00:00"
    }
}
