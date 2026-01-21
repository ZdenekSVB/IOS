//
//  GameMap.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 17.12.2025.
//

import FirebaseFirestore
import Foundation

struct GameMap: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let imageName: String
    let width: Double
    let height: Double

    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    
}
