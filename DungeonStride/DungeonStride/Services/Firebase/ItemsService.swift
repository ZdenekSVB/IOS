//
//  ItemsService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class ItemsService: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionPath = "items"
    
    @Published var items: [String: Any] = [:]
    
    func fetchAllItems() async throws -> [String: Any] {
        let snapshot = try await db.collection(collectionPath).getDocuments()
        var fetchedItems: [String: Any] = [:]
        for doc in snapshot.documents {
            fetchedItems[doc.documentID] = doc.data()
        }
        self.items = fetchedItems
        return fetchedItems
    }
    
    func fetchItem(itemId: String) async throws -> [String: Any]? {
        let doc = try await db.collection(collectionPath).document(itemId).getDocument()
        return doc.data()
    }
}
