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
    @Published var distance: Double = 0.0 // v metrech
    @Published var currentSpeed: Double = 0.0 // v metrech za sekundu (m/s)
    @Published var kcalBurned: Double = 0.0
    @Published var locationError: String?
    
    // MARK: - Private Properties
    private let locationManager = LocationManager()
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    private var previousLocation: CLLocation?
    private var speedHistory: [Double] = [] // Ukládáme rychlost v m/s
    
    // MARK: - Computed Properties
    // Vrací historii rychlosti v m/s (View si to převede na km/h)
    var rawSpeedHistory: [Double] {
        return speedHistory
    }
    
    // MARK: - Init
    init() {
        locationManager.requestPermission()
        setupBindings()
    }
    
    private func setupBindings() {
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
        
        elapsedTime = 0.0
        distance = 0.0
        currentSpeed = 0.0
        kcalBurned = 0.0
        currentPolyline = []
        previousLocation = nil
        speedHistory = []
    }
    
    // MARK: - Private Helpers
    
    private func stopTrackingAndTimer() {
        locationManager.stopTracking()
        timer?.cancel()
        timer = nil
    }
    
    private func subscribeToLocation() {
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
        
        currentRegion = MKCoordinateRegion(
            center: newLocation.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        
        if let previous = previousLocation {
            let delta = newLocation.distance(from: previous)
            distance += delta
            
            let timeDelta = newLocation.timestamp.timeIntervalSince(previous.timestamp)
            
            // Výpočet okamžité rychlosti (m/s)
            if delta > 0 && timeDelta > 0 {
                let speedMs = delta / timeDelta
                // Filtrace šumu: pokud je rychlost nesmyslně vysoká (např. chyba GPS), ignorujeme
                if speedMs < 50 { // < 180 km/h
                    speedHistory.append(speedMs)
                    currentSpeed = speedMs
                } else {
                    speedHistory.append(speedHistory.last ?? 0.0)
                }
            } else {
                speedHistory.append(0.0)
                currentSpeed = 0.0
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
        // Kalorie
        if distance > 0 {
            let userWeight: Double = 75.0 // TODO: Načíst z User profilu
            let hours = elapsedTime / 3600.0
            kcalBurned = selectedActivity.metValue * userWeight * hours
        }
        
        // Poznámka: currentSpeed se aktualizuje v handleNewLocation
        // Pokud se nehýbeme, ale čas běží, rychlost by měla klesat k nule,
        // ale pro jednoduchost necháváme poslední známou GPS rychlost nebo průměr.
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
        // Ukládáme průměrné tempo (min/km) pro zpětnou kompatibilitu, pokud je to potřeba,
        // nebo můžeme ukládat průměrnou rychlost. Zde nechávám logiku, která tam byla, jen optimalizovanou.
        let avgPaceMinKm = totalKm > 0 ? (elapsedTime / 60.0) / totalKm : 0.0
        
        let routeData = currentPolyline.map { ["lat": $0.latitude, "lon": $0.longitude] }
        
        // Convert history m/s -> km/h pro uložení (aby databáze měla konzistentní data jako dřív)
        let speedHistoryKmh = speedHistory.map { $0 * 3.6 }
        
        let record: [String: Any] = [
            "timestamp": FieldValue.serverTimestamp(),
            "type": selectedActivity.rawValue,
            "duration": elapsedTime,
            "distance_km": totalKm,
            "calories_kcal": kcalBurned,
            "avg_pace_min_km": avgPaceMinKm,
            "pace_history_min_km": speedHistoryKmh, // Ukládáme jako km/h (název pole v DB je matoucí, ale obsah bude rychlost)
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
