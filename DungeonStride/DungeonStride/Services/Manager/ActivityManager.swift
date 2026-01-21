//
//  ActivityManager.swift
//  DungeonStride
//

import SwiftUI
import CoreLocation
import MapKit
import Combine
import FirebaseFirestore

final class ActivityManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var activityState: ActivityState = .ready
    @Published var selectedActivity: ActivityType = .run
    
    // UI Data
    @Published var currentPolyline: [CLLocationCoordinate2D] = []
    @Published var currentRegion: MKCoordinateRegion?
    
    // Metrics
    @Published var elapsedTime: TimeInterval = 0.0
    @Published var distance: Double = 0.0
    @Published var pace: String = "0'00\" / km"
    @Published var kcalBurned: Double = 0.0
    @Published var locationError: String?
    
    // MARK: - Private Properties
    private let locationManager = LocationManager()
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    private var previousLocation: CLLocation?
    private var paceHistory: [Double] = [] // Ukládáme rychlost v km/h
    
    // MARK: - Computed Properties
    // Převod km/h na min/km pro graf
    var paceHistoryForChart: [Double] {
        paceHistory.map { speedKmH in
            guard speedKmH > 0 else { return 0.0 }
            return 60.0 / speedKmH
        }
    }
    
    // MARK: - Init
    init() {
        locationManager.requestPermission()
        setupBindings()
    }
    
    private func setupBindings() {
        // Propojení chyb z LocationManageru
        locationManager.$locationError
            .assign(to: \.locationError, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Activity Control
    
    func startActivity() {
        guard activityState != .active else { return }
        
        if activityState == .finished {
            resetActivity()
        }
        
        activityState = .active
        locationManager.startTracking()
        startTimer()
        subscribeToLocation()
        
        locationError = nil
    }
    
    func pauseActivity() {
        activityState = .paused
        stopTrackingAndTimer()
    }
    
    func finishActivity(userId: String?, userService: UserService?, questService: QuestService?) {
        activityState = .finished
        stopTrackingAndTimer()
        
        if let uid = userId, let service = userService {
            saveActivityData(userId: uid, userService: service, questService: questService)
        }
    }
    
    func resetActivity() {
        activityState = .ready
        stopTrackingAndTimer()
        
        // Reset dat
        elapsedTime = 0.0
        distance = 0.0
        pace = "0'00\" / km"
        kcalBurned = 0.0
        currentPolyline = []
        previousLocation = nil
        paceHistory = []
    }
    
    // MARK: - Private Helpers
    
    private func stopTrackingAndTimer() {
        locationManager.stopTracking()
        timer?.cancel()
        timer = nil
        // Location subscription se zruší v rámci logic, nebo můžeme nechat běžet 'listen', ale location manager data neposílá
    }
    
    private func subscribeToLocation() {
        // Zabráníme vícenásobnému odběru
        locationManager.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.handleNewLocation(location)
            }
            .store(in: &cancellables)
    }
    
    private func handleNewLocation(_ newLocation: CLLocation) {
        guard activityState == .active else { return }
        
        currentPolyline.append(newLocation.coordinate)
        
        // Update regionu pro mapu
        currentRegion = MKCoordinateRegion(
            center: newLocation.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        
        // Výpočty
        if let previous = previousLocation {
            let delta = newLocation.distance(from: previous)
            distance += delta
            
            let timeDelta = newLocation.timestamp.timeIntervalSince(previous.timestamp)
            
            // Okamžitá rychlost pro graf (km/h)
            if delta > 0 && timeDelta > 0 {
                let speedMs = delta / timeDelta
                paceHistory.append(speedMs * 3.6)
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
    
    private func updateMetrics() {
        // Průměrné tempo (text)
        if distance > 10.0 && elapsedTime > 0 {
            let totalKm = distance / 1000.0
            let minPerKm = (elapsedTime / 60.0) / totalKm
            
            let min = Int(minPerKm)
            let sec = Int((minPerKm - Double(min)) * 60)
            pace = String(format: "%d'%02d\" / km", min, sec)
        } else {
            pace = "0'00\" / km"
        }
        
        // Kalorie
        if distance > 0 {
            let userWeight: Double = 75.0 // TODO: Načíst z User profilu
            let hours = elapsedTime / 3600.0
            kcalBurned = selectedActivity.metValue * userWeight * hours
        }
    }
    
    func validateActivityType(for unit: DistanceUnit) {
        let isWater = unit == .nautical
        let isValid = isWater ? ActivityType.waterActivities.contains(selectedActivity) : ActivityType.landActivities.contains(selectedActivity)
        
        if !isValid {
            selectedActivity = isWater ? .swim : .run
        }
    }

    // MARK: - Data Saving
    private func saveActivityData(userId: String, userService: UserService, questService: QuestService?) {
        let totalKm = distance / 1000.0
        let avgPace = totalKm > 0 ? (elapsedTime / 60.0) / totalKm : 0.0
        
        // Optimalizace: Coordinates pro Firestore mapujeme až na konci
        let routeData = currentPolyline.map { ["lat": $0.latitude, "lon": $0.longitude] }
        
        let record: [String: Any] = [
            "timestamp": FieldValue.serverTimestamp(),
            "type": selectedActivity.rawValue,
            "duration": elapsedTime,
            "distance_km": totalKm,
            "calories_kcal": kcalBurned,
            "avg_pace_min_km": avgPace,
            "pace_history_min_km": paceHistoryForChart,
            "route_coordinates": routeData
        ]
        
        let steps = selectedActivity == .run ? Int(totalKm * 1250) : 0
        
        Task {
            if let updatedUser = try? await userService.saveRunActivity(
                userId: userId,
                activityData: record,
                distanceMeters: Int(distance),
                calories: Int(kcalBurned),
                steps: steps
            ) {
                await questService?.updateQuestsFromDailyStats(user: updatedUser)
            }
        }
    }
}
