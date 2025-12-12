//
//  ActivityType.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 05.11.2025.
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
