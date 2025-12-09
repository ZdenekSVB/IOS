//
//  DungeonMapLocation.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import Foundation
import UIKit
import FirebaseFirestore

struct DungeonMapLocation: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let x: Double
    let y: Double
    
    var position: CGPoint{
        return CGPoint(x: x, y: y)
    }
    
    
}
