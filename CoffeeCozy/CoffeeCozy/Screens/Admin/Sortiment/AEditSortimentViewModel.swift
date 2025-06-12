//  AEditSortimentViewModel.swift
//  CoffeeCozy

import SwiftUI
import PhotosUI

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

    init(item: SortimentItem? = nil) {
        if let item = item {
            self.name = item.name
            self.description = item.desc
            self.price = item.price
            self.isEditing = true
            self.originalURL = URL(string: item.image)
        } else {
            self.name = ""
            self.description = ""
            self.price = 0
            self.isEditing = false
            self.originalURL = nil
        }
    }

    var isValid: Bool {
        !name.isEmpty && !description.isEmpty && price > 0
    }

    func save() {
        // implement Firestore save
        if isEditing {
            print("Update: \(name), \(description), \(price)")
        } else {
            print("Create: \(name), \(description), \(price)")
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
