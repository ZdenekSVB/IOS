//
// ActivityType.swift
//

import Foundation

enum ActivityType: String, CaseIterable, Identifiable {
    case run = "Běh"
    case cycle = "Jízda na kole"
    var id: String { self.rawValue }
}

enum ActivityState {
    case ready
    case active
    case paused
    case finished
}
