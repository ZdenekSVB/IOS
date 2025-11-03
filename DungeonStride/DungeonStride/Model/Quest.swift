//
//  Quest.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct Quest: Identifiable {
    let id: Int
    let title: String
    let description: String
    var progress: Int
    let total: Int
    var isCompleted: Bool
}
