//
//  WatchWorkoutManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 19.01.2026.
//


//
//  WatchWorkoutManager.swift
//  DungeonStride Watch App
//

import Foundation
import HealthKit
import Combine

class WatchWorkoutManager: NSObject, ObservableObject {
    @Published var selectedActivity: ActivityType = .run
    @Published var running = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var heartRate: Double = 0
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            // Handle error
        }
    }
    
    func startWorkout(activityType: ActivityType) {
        let hkActivityType: HKWorkoutActivityType
        switch activityType {
        case .run: hkActivityType = .running
        case .cycle: hkActivityType = .cycling
        case .swim: hkActivityType = .swimming
        case .kayak: hkActivityType = .paddleSports
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = hkActivityType
        configuration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            return
        }
        
        session?.delegate = self
        builder?.delegate = self
        
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        
        session?.startActivity(with: Date())
        builder?.beginCollection(withStart: Date()) { (success, error) in
            DispatchQueue.main.async {
                self.running = true
            }
        }
    }
    
    func pauseWorkout() {
        session?.pause()
    }
    
    func resumeWorkout() {
        session?.resume()
    }
    
    func endWorkout() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { (success, error) in
            self.builder?.finishWorkout { (workout, error) in
                DispatchQueue.main.async {
                    self.running = false
                    self.sendDataToPhone() // Odeslat data po skončení
                    self.resetValues()
                }
            }
        }
    }
    
    func resetValues() {
        elapsedTime = 0
        distance = 0
        activeEnergy = 0
        heartRate = 0
    }
    
    private func sendDataToPhone() {
        // Připravíme data ve formátu, který očekává tvůj iOS ActivityManager/Firebase
        let workoutData: [String: Any] = [
            "type": selectedActivity.rawValue,
            "duration": elapsedTime,
            "distance": distance, // metry
            "calories": activeEnergy,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        WatchConnectivityManager.shared.sendWorkoutToPhone(data: workoutData)
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WatchWorkoutManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            DispatchQueue.main.async {
                self.updateMetrics(statistics: statistics)
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
    
    private func updateMetrics(statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            let energyUnit = HKUnit.kilocalorie()
            self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            
        case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
             HKQuantityType.quantityType(forIdentifier: .distanceCycling):
            let meterUnit = HKUnit.meter()
            self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            
        default:
            return
        }
    }
}
