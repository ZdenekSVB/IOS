//
//  AEditSortimentViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

class AEditSortimentViewModel: ObservableObject {
    @Published var name: String
    @Published var description: String
    @Published var price: Double
    @Published var imageURL: String

    let isEditing: Bool
    private let db = Firestore.firestore()
    private var existingItemID: String?

    init(item: SortimentItem? = nil) {
        if let item = item {
            name = item.name
            description = item.desc
            price = item.price
            imageURL = item.image
            isEditing = true
            existingItemID = item.id
        } else {
            name = ""
            description = ""
            price = 0
            imageURL = ""
            isEditing = false
            existingItemID = nil
        }
    }

    var isValid: Bool {
        !name.isEmpty && !description.isEmpty && price > 0
    }

    func save() {
        let data: [String: Any] = [
            "name": name,
            "description": description,
            "price": price,
            "image": imageURL,
            "numOfOrders": 0,
            "category": "Coffee"
        ]

        if let id = existingItemID {
            db.collection("sortiment").document(id).setData(data, merge: true) { error in
                if let error = error {
                    print("Chyba při aktualizaci: \(error.localizedDescription)")
                } else {
                    print("Položka upravena")
                    ReportLogger.log(.nameChange, message: "Item updated: \(self.name)")
                }
            }
        } else {
            db.collection("sortiment").addDocument(data: data) { error in
                if let error = error {
                    print("Chyba při vytvoření: \(error.localizedDescription)")
                } else {
                    print("Položka přidána")
                    ReportLogger.log(.registration, message: "New item added: \(self.name)")
                }
            }
        }
    }
}
