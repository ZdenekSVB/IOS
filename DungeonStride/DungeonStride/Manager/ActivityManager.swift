//
//  ActivityManager.swift
//  DungeonStride
//

import SwiftUI
import CoreLocation
import MapKit
import HealthKit
import Combine
import FirebaseFirestore
import Charts

final class ActivityManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Publishers
    @Published var selectedActivity: ActivityType = .run
    @Published var activityState: ActivityState = .ready
    @Published var elapsedTime: TimeInterval = 0.0
    @Published var distance: Double = 0.0
    @Published var pace: String = "0'00\" / km"
    @Published var kcalBurned: Double = 0.0
    @Published var currentPolyline: [CLLocationCoordinate2D] = []
    @Published var currentRegion: MKCoordinateRegion?
    @Published var locationError: String?
    
    // MARK: - Internal Properties
    private var locationManager = CLLocationManager()
    private var timer: AnyCancellable?
    private var previousLocation: CLLocation?
    private var paceHistory: [Double] = []
    
    var paceHistoryForChart: [Double] {
        paceHistory.map { speedKmPerHour in
            guard speedKmPerHour > 0 else { return 0.0 }
            return (1.0 / speedKmPerHour) * 60.0
        }
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        requestHealthKitAuthorization()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        
        // Uncomment if Background Modes are enabled in Capabilities
        // locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Activity Control
    func startActivity() {
        if activityState == .active { return }
        
        if activityState == .ready || activityState == .finished {
            resetActivity()
        }
        
        activityState = .active
        locationManager.startUpdatingLocation()
        startTimer()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationError = nil
    }
    
    func pauseActivity() {
        activityState = .paused
        locationManager.stopUpdatingLocation()
        timer?.cancel()
    }
    
    func finishActivity(userId: String?, userService: UserService?) {
        activityState = .finished
        locationManager.stopUpdatingLocation()
        timer?.cancel()
        
        if let uid = userId, let service = userService {
            saveActivityData(userId: uid, userService: service)
        }
    }
    
    func resetActivity() {
        activityState = .ready
        locationManager.stopUpdatingLocation()
        timer?.cancel()
        
        elapsedTime = 0.0
        distance = 0.0
        pace = "0'00\" / km"
        kcalBurned = 0.0
        currentPolyline = []
        previousLocation = nil
        paceHistory = []
    }
    
    // MARK: - CoreLocation Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard activityState == .active, let newLocation = locations.last else { return }
        
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 50 { return }
        
        currentPolyline.append(newLocation.coordinate)
        
        currentRegion = MKCoordinateRegion(
            center: newLocation.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        
        if let previousLocation = previousLocation {
            let segmentDistance = newLocation.distance(from: previousLocation)
            distance += segmentDistance
            
            let timeElapsed = newLocation.timestamp.timeIntervalSince(previousLocation.timestamp)
            if segmentDistance > 0 && timeElapsed > 0 {
                let speedMetersPerSecond = segmentDistance / timeElapsed
                let speedKmPerHour = speedMetersPerSecond * 3.6
                paceHistory.append(speedKmPerHour)
            } else {
                paceHistory.append(0.0)
            }
        }
        
        previousLocation = newLocation
        updateMetrics()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            locationError = "Povolte prosím přístup k poloze v nastavení."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
    
    // MARK: - Metrics Logic
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.activityState == .active else { return }
                self.elapsedTime += 1.0
                self.updateMetrics()
            }
    }
    
    private func updateMetrics() {
        if distance > 10.0 && elapsedTime > 0 {
            let totalKilometers = distance / 1000.0
            let minutesPerKilometer = (elapsedTime / 60.0) / totalKilometers
            
            let minutes = Int(minutesPerKilometer)
            let seconds = Int((minutesPerKilometer - Double(minutes)) * 60)
            pace = String(format: "%d'%02d\" / km", minutes, seconds)
        } else {
            pace = "0'00\" / km"
        }
        
        if distance > 0 {
            let metValue: Double = (selectedActivity == .run) ? 7.0 : 4.0
            let userWeight: Double = 70.0 // Placeholder pro váhu uživatele
            let timeInHours = elapsedTime / 3600.0
            kcalBurned = metValue * userWeight * timeInHours
        } else {
            kcalBurned = 0.0
        }
    }
    
    // MARK: - HealthKit & Saving
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]
        HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }
    
    private func saveActivityData(userId: String, userService: UserService) {
        let totalKilometers = distance / 1000.0
        let avgPaceMinPerKm = totalKilometers > 0 ? (elapsedTime / 60.0) / totalKilometers : 0.0
        
        let routeData = currentPolyline.map { ["lat": $0.latitude, "lon": $0.longitude] }
        
        let activityRecord: [String: Any] = [
            "timestamp": FieldValue.serverTimestamp(),
            "type": selectedActivity.rawValue,
            "duration": elapsedTime,
            "distance_km": totalKilometers,
            "calories_kcal": kcalBurned,
            "avg_pace_min_km": avgPaceMinPerKm,
            "pace_history_min_km": paceHistoryForChart,
            "route_coordinates": routeData
        ]
        
        let estimatedSteps = Int(totalKilometers * 1250)
        
        print("💾 Saving activity for user: \(userId)")
        
        Task {
            do {
                try await userService.saveRunActivity(
                    userId: userId,
                    activityData: activityRecord,
                    distanceMeters: Int(distance),
                    calories: Int(kcalBurned),
                    steps: estimatedSteps
                )
            } catch {
                print("❌ Failed to save activity: \(error.localizedDescription)")
            }
        }
    }
}
