//  AEditSortimentViewModel.swift
//  CoffeeCozy

import SwiftUI
import PhotosUI
import FirebaseFirestore

class AEditSortimentViewModel: ObservableObject {
    @Published var name: String
    @Published var description: String
    @Published var price: Double
    @Published var image: UIImage?
    @Published var selectedImageItem: PhotosPickerItem? {
        didSet { loadImage() }
    }

    let isEditing: Bool
    let originalURL: URL?

    private var db = Firestore.firestore()
    private var existingItemID: String?

    init(item: SortimentItem? = nil) {
        if let item = item {
            self.name = item.name
            self.description = item.desc
            self.price = item.price
            self.isEditing = true
            self.originalURL = URL(string: item.image)
            self.existingItemID = item.id
        } else {
            self.name = ""
            self.description = ""
            self.price = 0
            self.isEditing = false
            self.originalURL = nil
            self.existingItemID = nil
        }
    }

    var isValid: Bool {
        !name.isEmpty && !description.isEmpty && price > 0
    }

    func save() {
        let imageURL = originalURL?.absoluteString ?? "" // později nahradit skutečnou URL obrázku

        let data: [String: Any] = [
            "name": name,
            "description": description,
            "price": price,
            "image": imageURL,
            "numOfOrders": 0,
            "category": "Coffee" // nebo předat jinak
        ]

        if let id = existingItemID {
            db.collection("sortiment").document(id).setData(data, merge: true) { error in
                if let error = error {
                    print("Chyba při aktualizaci: \(error.localizedDescription)")
                } else {
                    print("Položka upravena")
                }
            }
        } else {
            db.collection("sortiment").addDocument(data: data) { error in
                if let error = error {
                    print("Chyba při vytvoření: \(error.localizedDescription)")
                } else {
                    print("Položka přidána")
                }
            }
        }
    }

    private func loadImage() {
        Task {
            if let data = try? await selectedImageItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                }
            }
        }
    }
}
