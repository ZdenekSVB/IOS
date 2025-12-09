//
// ActivityManager.swift
//

import SwiftUI
import CoreLocation
import MapKit
import HealthKit
import Combine
import FirebaseFirestore
import Charts

// Předpokládáme existenci ActivityType a ActivityState v ActivityType.swift

final class ActivityManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Publishers (Data pro View)
    @Published var selectedActivity: ActivityType = .run
    @Published var activityState: ActivityState = .ready
    @Published var elapsedTime: TimeInterval = 0.0 // Nyní funguje jako čítač sekund
    @Published var distance: Double = 0.0 // v metrech
    @Published var pace: String = "0'00\" / km"
    @Published var kcalBurned: Double = 0.0
    @Published var currentPolyline: [CLLocationCoordinate2D] = []
    @Published var currentRegion: MKCoordinateRegion?
    @Published var locationError: String?
    
    // MARK: - Interní proměnné
    private var locationManager = CLLocationManager()
    private var timer: AnyCancellable?
    private var previousLocation: CLLocation?
    private var paceHistory: [Double] = [] // km/hod pro interní ukládání
    
    // Vypočítaná proměnná pro Swift Charts (min/km)
    var paceHistoryForChart: [Double] {
        paceHistory.map { speedKmPerHour in
            guard speedKmPerHour > 0 else { return 0.0 }
            return (1.0 / speedKmPerHour) * 60.0
        }
    }
    
    // MARK: - Inicializace
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // Zde zakomentujte, pokud nemáte Background Modes zapnuté v Capabilities
        // locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.activityType = .fitness
        
        locationManager.requestWhenInUseAuthorization()
        requestHealthKitAuthorization()
    }
    
    // MARK: - Metody pro ovládání aktivity
    
    func startActivity() {
        if activityState == .active { return }
        
        // Pokud startujeme z "ready" nebo "finished", resetujeme data
        if activityState == .ready || activityState == .finished {
            resetActivity()
        }
        
        // Pokud jsme byli "paused", pouze pokračujeme (neresetujeme)
        
        activityState = .active
        locationManager.startUpdatingLocation()
        startTimer()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationError = nil
    }
    
    func pauseActivity() {
        activityState = .paused
        locationManager.stopUpdatingLocation()
        // Zrušíme timer, takže se elapsedTime přestane přičítat
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
        
        // Ignorujeme stará nebo nepřesná data
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 50 { return }
        
        currentPolyline.append(newLocation.coordinate)
        
        // Centrování mapy
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
        
        // Aktualizace metrik při každém pohybu
        updateMetrics()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            locationError = "Povolte prosím přístup k poloze v nastavení."
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
    
    // MARK: - Timer & Metriky
    
    private func startTimer() {
        // Zrušíme předchozí timer pro jistotu
        timer?.cancel()
        
        // Timer, který každou sekundu přičte 1 k elapsedTime
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.activityState == .active else { return }
                self.elapsedTime += 1.0
                self.updateMetrics()
            }
    }
    
    private func updateMetrics() {
        // 1. Tempo
        if distance > 10.0 && elapsedTime > 0 {
            let totalKilometers = distance / 1000.0
            let minutesPerKilometer = (elapsedTime / 60.0) / totalKilometers
            
            let minutes = Int(minutesPerKilometer)
            let seconds = Int((minutesPerKilometer - Double(minutes)) * 60)
            pace = String(format: "%d'%02d\" / km", minutes, seconds)
        } else {
            pace = "0'00\" / km"
        }
        
        // 2. Kalorie
        // POŽADAVEK: Pokud se nehýbu (distance se nemění), tak 0 kcal.
        // Jednoduchá logika: Pokud je průměrná rychlost velmi malá nebo vzdálenost 0, kcal = 0.
        // Nebo: počítat jen za ušlou vzdálenost.
        
        if distance > 0 {
            let metValue: Double = (selectedActivity == .run) ? 7.0 : 4.0
            let userWeight: Double = 70.0 // Placeholder
            let timeInHours = elapsedTime / 3600.0
            
            // Standardní vzorec
            let calculatedKcal = metValue * userWeight * timeInHours
            
            kcalBurned = calculatedKcal
        } else {
            kcalBurned = 0.0
        }
    }
    
    // MARK: - HealthKit (Placeholder)
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]
        HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }
    
    // MARK: - Ukládání dat (Přes UserService)
    
    private func saveActivityData(userId: String, userService: UserService) {
        
        let totalKilometers = distance / 1000.0
        let avgPaceMinPerKm = totalKilometers > 0 ? (elapsedTime / 60.0) / totalKilometers : 0.0
        
        // Převedeme [CLLocationCoordinate2D] na pole slovníků pro Firestore
        let routeData = currentPolyline.map { ["lat": $0.latitude, "lon": $0.longitude] }
        
        // Data aktivity
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
        
        // Odhad kroků (přibližně 1250 kroků na 1 km běhu)
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
