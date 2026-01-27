//
//  DeathStats.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 27.01.2026.
//

import FirebaseFirestore
import Foundation

struct DeathStats: Codable {
    var diedAt: Date
    var requiredDistance: Double
    var distanceRunSoFar: Double
    var causeOfDeath: String?
    
    var isReadyToRevive: Bool {
        return distanceRunSoFar >= requiredDistance
    }
    
    var progress: Double {
        guard requiredDistance > 0 else { return 1.0 }
        return min(distanceRunSoFar / requiredDistance, 1.0)
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "diedAt": Timestamp(date: diedAt),
            "requiredDistance": requiredDistance,
            "distanceRunSoFar": distanceRunSoFar,
            "causeOfDeath": causeOfDeath ?? ""
        ]
    }
    
    static func fromFirestore(_ data: [String: Any]) -> DeathStats {
        return DeathStats(
            diedAt: (data["diedAt"] as? Timestamp)?.dateValue() ?? Date(),
            requiredDistance: data["requiredDistance"] as? Double ?? 2000.0,
            distanceRunSoFar: data["distanceRunSoFar"] as? Double ?? 0.0,
            causeOfDeath: data["causeOfDeath"] as? String
        )
    }
}
