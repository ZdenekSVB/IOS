//
//  DungeonMapLocation.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import Foundation
import UIKit
import FirebaseFirestore

struct GameMapLocation: Codable, Identifiable {
    @DocumentID var id: String?
    
    let mapId: String
    let name: String
    let description: String?
    let locationType: String
    let x: Double
    let y: Double
    
    var position: CGPoint {
        return CGPoint(x: x, y: y)
    }
}
