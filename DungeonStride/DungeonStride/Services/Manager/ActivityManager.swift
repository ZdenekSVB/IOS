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

final class ActivityManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var activityState: ActivityState = .ready
    @Published var selectedActivity: ActivityType = .run
    
    @Published var currentPolyline: [CLLocationCoordinate2D] = []
    @Published var currentRegion: MKCoordinateRegion?
    
    @Published var elapsedTime: TimeInterval = 0.0
    @Published var distance: Double = 0.0
    @Published var pace: String = "0'00\" / km"
    @Published var kcalBurned: Double = 0.0
    @Published var locationError: String?
    
    // MARK: - Private Properties
    private let locationManager = LocationManager() 
    private var timer: AnyCancellable?
    private var locationSubscription: AnyCancellable?
    private var errorSubscription: AnyCancellable?
    
    private var previousLocation: CLLocation?
    private var paceHistory: [Double] = []
    
    private let firestore = Firestore.firestore()
    
    // MARK: - Computed Properties
    var paceHistoryForChart: [Double] {
        paceHistory.map { speedKmPerHour in
            guard speedKmPerHour > 0 else { return 0.0 }
            return (1.0 / speedKmPerHour) * 60.0
        }
    }
    
    // MARK: - Init
    init() {
        // Požádáme o oprávnění přes LocationManager
        locationManager.requestPermission()
        setupBindings()
    }
    
    private func setupBindings() {
        // Naslouchání chybám z LocationManageru
        errorSubscription = locationManager.$locationError
            .assign(to: \.locationError, on: self)
    }
    
    // MARK: - Activity Control
    
    func startActivity() {
        guard activityState != .active else { return }
        
        if activityState != .paused {
            resetActivity()
        }
        
        activityState = .active
        locationManager.startTracking()
        startTimer()
        startLocationUpdates() // Začneme odebírat data z LocationManageru
        
        locationError = nil
    }
    
    func pauseActivity() {
        activityState = .paused
        locationManager.stopTracking()
        stopTimer()
    }
    
    func finishActivity(userId: String?, userService: UserService?, questService: QuestService?) {
        activityState = .finished
        locationManager.stopTracking()
        stopTimer()
        locationSubscription?.cancel() // Přestaneme naslouchat poloze
        
        if let uid = userId, let service = userService {
            saveActivityData(userId: uid, userService: service, questService: questService)
        }
    }
    
    func resetActivity() {
        activityState = .ready
        locationManager.stopTracking()
        stopTimer()
        locationSubscription?.cancel()
        
        elapsedTime = 0.0
        distance = 0.0
        pace = "0'00\" / km"
        kcalBurned = 0.0
        currentPolyline = []
        previousLocation = nil
        paceHistory = []
    }
    
    // MARK: - Logic & Updates
    
    private func startLocationUpdates() {
        // Reagujeme na změnu `lastLocation` v LocationManageru
        locationSubscription = locationManager.$lastLocation
            .compactMap { $0 } // Ignorujeme nil hodnoty
            .sink { [weak self] newLocation in
                self?.handleNewLocation(newLocation)
            }
    }
    
    private func handleNewLocation(_ newLocation: CLLocation) {
        guard activityState == .active else { return }
        
        // 1. Přidání do polyline
        currentPolyline.append(newLocation.coordinate)
        
        // 2. Update mapy
        currentRegion = MKCoordinateRegion(
            center: newLocation.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        
        // 3. Výpočty vzdálenosti a rychlosti
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
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.activityState == .active else { return }
                self.elapsedTime += 1.0
                self.updateMetrics()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func updateMetrics() {
        // Výpočet tempa
        if distance > 10.0 && elapsedTime > 0 {
            let totalKilometers = distance / 1000.0
            let minutesPerKilometer = (elapsedTime / 60.0) / totalKilometers
            
            let minutes = Int(minutesPerKilometer)
            let seconds = Int((minutesPerKilometer - Double(minutes)) * 60)
            pace = String(format: "%d'%02d\" / km", minutes, seconds)
        } else {
            pace = "0'00\" / km"
        }
        
        // Výpočet kalorií
        if distance > 0 {
            let userWeight: Double = 75.0 // Zde by se měla brát váha z User profilu
            let timeInHours = elapsedTime / 3600.0
            kcalBurned = selectedActivity.metValue * userWeight * timeInHours
        } else {
            kcalBurned = 0.0
        }
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

    // MARK: - Data Saving
    
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
            if let updatedUser = try? await userService.saveRunActivity(
                userId: userId,
                activityData: activityRecord,
                distanceMeters: Int(distance),
                calories: Int(kcalBurned),
                steps: estimatedSteps
            ) {
                await questService?.updateQuestsFromDailyStats(user: updatedUser)
            }
        }
    }
}
