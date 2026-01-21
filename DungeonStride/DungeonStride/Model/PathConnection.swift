//
//  PathConnection.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 21.01.2026.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct PathConnection: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
    let curveAmount: Double
}
