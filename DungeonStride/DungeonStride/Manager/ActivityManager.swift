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
    
    @Published var selectedActivity: ActivityType = .run
    @Published var activityState: ActivityState = .ready
    @Published var elapsedTime: TimeInterval = 0.0
    @Published var distance: Double = 0.0
    @Published var pace: String = "0'00\" / km"
    @Published var kcalBurned: Double = 0.0
    @Published var currentPolyline: [CLLocationCoordinate2D] = []
    @Published var currentRegion: MKCoordinateRegion?
    @Published var locationError: String?
    
    private var locationManager = CLLocationManager()
    private var timer: AnyCancellable?
    private var previousLocation: CLLocation?
    private var paceHistory: [Double] = []
    
    private let firestore = Firestore.firestore()
    
    var paceHistoryForChart: [Double] {
        paceHistory.map { speedKmPerHour in
            guard speedKmPerHour > 0 else { return 0.0 }
            return (1.0 / speedKmPerHour) * 60.0
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
        
        locationManager.requestWhenInUseAuthorization()
        requestHealthKitAuthorization()
    }
    
    func startActivity() {
        guard activityState != .active else { return }
        
        if activityState != .paused {
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
    
    // Zde přijímáme questService
    func finishActivity(userId: String?, userService: UserService?, questService: QuestService?) {
        activityState = .finished
        locationManager.stopUpdatingLocation()
        timer?.cancel()
        
        if let uid = userId, let service = userService {
            saveActivityData(userId: uid, userService: service, questService: questService)
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
    
    func validateActivityType(for unit: DistanceUnit) {
        if unit == .nautical {
            if !ActivityType.waterActivities.contains(selectedActivity) {
                selectedActivity = .swim
            }
        } else {
            if !ActivityType.landActivities.contains(selectedActivity) {
                selectedActivity = .run
            }
        }
    }
    
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
        switch manager.authorizationStatus {
        case .denied, .restricted:
            locationError = "Please enable location access in settings."
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
    
    private func startTimer() {
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
            let userWeight: Double = 75.0
            let timeInHours = elapsedTime / 3600.0
            
            kcalBurned = selectedActivity.metValue * userWeight * timeInHours
        } else {
            kcalBurned = 0.0
        }
    }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!]
        HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }
    
    private func saveActivityData(userId: String, userService: UserService, questService: QuestService?) {
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
        
        let estimatedSteps = selectedActivity == .run ? Int(totalKilometers * 1250) : 0
        
        Task {
            // 1. Uložit aktivitu a získat aktualizovaného uživatele (s novým dailyActivity)
            if let updatedUser = try? await userService.saveRunActivity(
                userId: userId,
                activityData: activityRecord,
                distanceMeters: Int(distance),
                calories: Int(kcalBurned),
                steps: estimatedSteps
            ) {
                // 2. Aktualizovat questy podle nových denních statistik z Firestore/User modelu
                await questService?.updateQuestsFromDailyStats(user: updatedUser)
            }
        }
    }
    // Přidej do ActivityManager.swift na iOS

    func listenForWatchData(userId: String, userService: UserService, questService: QuestService) {
        // Naslouchání na notifikace z WatchConnectivityManager
        NotificationCenter.default.addObserver(forName: NSNotification.Name("WorkoutReceived"), object: nil, queue: .main) { [weak self] notification in
            
            // OPRAVA: Přidáno přetypování 'as? [String: Any]'
            guard let self = self,
                  let rawUserInfo = notification.userInfo,
                  let userInfo = rawUserInfo as? [String: Any] else { return }
            
            self.processWatchData(userInfo, userId: userId, userService: userService, questService: questService)
        }
    }

    private func processWatchData(_ data: [String: Any], userId: String, userService: UserService, questService: QuestService) {
        guard
            let typeRaw = data["type"] as? String,
            let duration = data["duration"] as? TimeInterval,
            let distanceMeters = data["distance"] as? Double,
            let calories = data["calories"] as? Double,
            let timestamp = data["timestamp"] as? TimeInterval
        else { return }
        
        let distanceKm = distanceMeters / 1000.0
        let avgPace = distanceKm > 0 ? (duration / 60.0) / distanceKm : 0.0
        let estimatedSteps = typeRaw == ActivityType.run.rawValue ? Int(distanceKm * 1250) : 0
        
        // Vytvoření záznamu pro Firestore
        let activityRecord: [String: Any] = [
            "timestamp": Date(timeIntervalSince1970: timestamp),
            "type": typeRaw,
            "duration": duration,
            "distance_km": distanceKm,
            "calories_kcal": calories,
            "avg_pace_min_km": avgPace,
            "pace_history_min_km": [], // Z hodinek zatím neposíláme detailní graf
            "route_coordinates": []    // Z hodinek pro úsporu baterie často nemáme detailní GPS trasu, pokud ji explicitně neposbíráme
        ]
        
        // Uložení pomocí existující logiky
        Task {
            if let updatedUser = try? await userService.saveRunActivity(
                userId: userId,
                activityData: activityRecord,
                distanceMeters: Int(distanceMeters),
                calories: Int(calories),
                steps: estimatedSteps
            ) {
                await questService.updateQuestsFromDailyStats(user: updatedUser)
                print("Activity from Watch saved successfully!")
            }
        }
    }
}
