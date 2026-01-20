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
    
    private let db = Firestore.firestore()
    
    func fetchHistory(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("📜 HistoryViewModel: Začínám stahovat historii pro uživatele \(userId)...")
            
            // Stáhneme posledních 50 aktivit
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("activities")
                .order(by: "timestamp", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            print("📜 HistoryViewModel: Nalezeno \(snapshot.documents.count) dokumentů.")
            
            var loadedActivities: [RunActivity] = []
            
            for document in snapshot.documents {
                let data = document.data()
                let docId = document.documentID
                
                // 1. Manuální extrakce dat (bezpečnější než Codable)
                // Pokud nějaké pole chybí, použijeme výchozí hodnotu, aby aplikace nespadla/nepřeskočila záznam.
                
                let type = data["type"] as? String ?? "run"
                
                // Distance: Může být uloženo jako Int nebo Double, převedeme na Double
                let distanceKm = (data["distance_km"] as? NSNumber)?.doubleValue ?? 0.0
                
                let duration = (data["duration"] as? NSNumber)?.doubleValue ?? 0.0
                
                // Calories: Uloženo jako Double, chceme Int
                let caloriesDouble = (data["calories_kcal"] as? NSNumber)?.doubleValue ?? 0.0
                let calories = Int(caloriesDouble)
                
                let pace = (data["avg_pace_min_km"] as? NSNumber)?.doubleValue ?? 0.0
                
                // Timestamp
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                
                // 2. Extrakce souřadnic pro mapu
                var parsedCoordinates: [CLLocationCoordinate2D]? = nil
                if let rawCoordinates = data["route_coordinates"] as? [[String: Double]] {
                    parsedCoordinates = rawCoordinates.compactMap { point in
                        guard let lat = point["lat"], let lon = point["lon"] else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
                
                // 3. Vytvoření instance RunActivity
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
            print("✅ HistoryViewModel: Úspěšně načteno \(loadedActivities.count) aktivit.")
            
        } catch {
            print("❌ HistoryViewModel Error: \(error.localizedDescription)")
            self.errorMessage = "Nepodařilo se načíst historii: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
