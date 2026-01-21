//
//  DungeonMapService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class DungeonMapService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionPath = "dungeon_locations" // Doplněn název kolekce
    
    func fetchLocations() async throws -> [GameMapLocation] {
        let snapshot = try await db.collection(collectionPath).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: GameMapLocation.self)
        }
    }
}
