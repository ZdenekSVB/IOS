//  ASortimentViewModel.swift
//  CoffeeCozy

import Foundation

class ASortimentViewModel: ObservableObject {
    @Published var items: [SortimentItem] = []
    @Published var searchText = ""

    var filteredItems: [SortimentItem] {
        searchText.isEmpty
            ? items
            : items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func loadItems() {
        items = [
            .init(id: "1",
                  name: "Coffee",
                  description: "Strong and aromatic",
                  price: 89,
                  imageURL: "https://pxhere.com/photo/646824/download"),
            .init(id: "2",
                  name: "Tea",
                  description: "Green with lemon",
                  price: 49,
                  imageURL: "https://upload.wikimedia.org/wikipedia/commons/3/3e/Zeleny-caj.jpg")
        ]
    }
}
