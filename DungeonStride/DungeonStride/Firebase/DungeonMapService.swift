//
//  DungeonMapService.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class DungeonMapService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionPath = ""
    
    func fetchLocations() async throws -> [DungeonMapLocation] {
            let snapshot = try await db.collection(collectionPath).getDocuments()
            
            // Mapování Firestore dokumentů na strukturu MapLocation
            return snapshot.documents.compactMap { document in
                // Používáme FirebaseFirestoreSwift pro snadné dekódování
                try? document.data(as: DungeonMapLocation.self)
            }
        }
}
