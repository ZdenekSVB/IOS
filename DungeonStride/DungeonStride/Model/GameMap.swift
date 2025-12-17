//
//  GameMap.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 17.12.2025.
//

import Foundation
import FirebaseFirestore
 
struct GameMap: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let imageName: String
    let size: CGSize        
}
