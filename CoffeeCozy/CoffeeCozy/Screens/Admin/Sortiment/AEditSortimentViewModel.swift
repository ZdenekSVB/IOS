//  AEditSortimentViewModel.swift
//  CoffeeCozy

import SwiftUI
import PhotosUI
import FirebaseFirestore

class AEditSortimentViewModel: ObservableObject {
    @Published var name: String
    @Published var description: String
    @Published var price: Double
    @Published var imageURL: String

    let isEditing: Bool
    private var db = Firestore.firestore()
    private var existingItemID: String?

    init(item: SortimentItem? = nil) {
        if let item = item {
            self.name = item.name
            self.description = item.desc
            self.price = item.price
            self.imageURL = item.image
            self.isEditing = true
            self.existingItemID = item.id
        } else {
            self.name = ""
            self.description = ""
            self.price = 0
            self.imageURL = ""
            self.isEditing = false
            self.existingItemID = nil
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
