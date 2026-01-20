//
//  HistoryViewModel.swift
//  DungeonStride
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var activities: [RunActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // --- FILTERING ---
    @Published var filterStartDate: Date = Date()
    @Published var filterEndDate: Date = Date()
    @Published var isFilterExpanded: Bool = false
    
    // This property returns only activities falling within the selected range
    var filteredActivities: [RunActivity] {
        let calendar = Calendar.current
        
        // Ensure we cover the full day (from 00:00:00 to 23:59:59)
        let start = calendar.startOfDay(for: filterStartDate)
        guard let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: filterEndDate) else {
            return activities
        }
        
        return activities.filter { activity in
            return activity.timestamp >= start && activity.timestamp <= end
        }
    }
    
    private let db = Firestore.firestore()
    
    func fetchHistory(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("📜 HistoryViewModel: Starting history fetch for user \(userId)...")
            
            // Fetch last 50 activities
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("activities")
                .order(by: "timestamp", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            print("📜 HistoryViewModel: Found \(snapshot.documents.count) documents.")
            
            var loadedActivities: [RunActivity] = []
            
            for document in snapshot.documents {
                let data = document.data()
                let docId = document.documentID
                
                // 1. Manual extraction
                let type = data["type"] as? String ?? "run"
                let distanceKm = (data["distance_km"] as? NSNumber)?.doubleValue ?? 0.0
                let duration = (data["duration"] as? NSNumber)?.doubleValue ?? 0.0
                let caloriesDouble = (data["calories_kcal"] as? NSNumber)?.doubleValue ?? 0.0
                let calories = Int(caloriesDouble)
                let pace = (data["avg_pace_min_km"] as? NSNumber)?.doubleValue ?? 0.0
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                
                // 2. Parse coordinates
                var parsedCoordinates: [CLLocationCoordinate2D]? = nil
                if let rawCoordinates = data["route_coordinates"] as? [[String: Double]] {
                    parsedCoordinates = rawCoordinates.compactMap { point in
                        guard let lat = point["lat"], let lon = point["lon"] else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
                
                // 3. Create instance
                let activity = RunActivity(
                    id: docId,
                    type: type,
                    distanceKm: distanceKm,
                    duration: duration,
                    calories: calories,
                    pace: pace,
                    timestamp: timestamp,
                    routeCoordinates: parsedCoordinates
                )
                
                loadedActivities.append(activity)
            }
            
            self.activities = loadedActivities
            
            // Set default filter values based on loaded data
            if let oldestDate = loadedActivities.last?.timestamp {
                self.filterStartDate = oldestDate
            } else {
                // Default to 30 days ago if empty
                self.filterStartDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            }
            self.filterEndDate = Date()
            
            print("✅ HistoryViewModel: Successfully loaded \(loadedActivities.count) activities.")
            
        } catch {
            print("❌ HistoryViewModel Error: \(error.localizedDescription)")
            self.errorMessage = "Failed to load history: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
