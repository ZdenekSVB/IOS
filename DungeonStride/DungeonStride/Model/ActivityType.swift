//
//  ActivityType.swift
//  DungeonStride
//

import Foundation

enum ActivityType: String, CaseIterable, Identifiable, Codable {
    case run = "Running"
    case cycle = "Cycling"
    case swim = "Swimming"
    case kayak = "Kayaking"
    
    var id: String { self.rawValue }
    
    var metValue: Double {
        switch self {
        case .run: return 9.8
        case .cycle: return 7.5
        case .swim: return 8.0
        case .kayak: return 5.0
        }
    }
    
    static var landActivities: [ActivityType] {
        [.run, .cycle]
    }
    
    static var waterActivities: [ActivityType] {
        [.swim, .kayak]
    }
}

enum ActivityState {
    case ready
    case active
    case paused
    case finished
}
