//
//  DungeonMapLocation.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import FirebaseFirestore
import Foundation
import UIKit

struct GameMapLocation: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let name: String
    let description: String?
    let locationType: String
    let x: Double
    let y: Double

    var position: CGPoint {
        return CGPoint(x: x, y: y)
    }

    static func == (lhs: GameMapLocation, rhs: GameMapLocation) -> Bool {
        return lhs.id == rhs.id
    }
}
