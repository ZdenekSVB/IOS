//
//  EnemyService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class EnemyService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionPath = "enemies"
    
    func fetchEnemies(forBiome biome: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection(collectionPath)
            .whereField("biome", isEqualTo: biome)
            .getDocuments()
        return snapshot.documents.map { $0.data() }
    }
    
    func fetchBoss(id: String) async throws -> [String: Any]? {
        let doc = try await db.collection(collectionPath).document(id).getDocument()
        return doc.data()
    }
}
