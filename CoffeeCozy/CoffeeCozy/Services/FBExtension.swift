//
//  FBExtension.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//
import FirebaseFirestore

extension DocumentReference {
    func getDocument<T: Decodable>(as type: T.Type) async throws -> T {
        let snapshot = try await self.getDocument()
        return try snapshot.data(as: type)
    }
}

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map { try $0.data(as: type) }
    }
}
