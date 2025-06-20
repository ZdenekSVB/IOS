//
//  SortimentViewModel.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import Foundation
import FirebaseFirestore

class SortimentViewModel: ObservableObject {
    @Published var items: [SortimentItem] = []
    
    private var db = Firestore.firestore()
    
    init() {
        fetchItems()
    }
    
    func fetchItems() {
        db.collection("sortiment").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Chyba při načítání: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Žádná data v sortimentu")
                return
            }

            self.items = documents.compactMap { doc -> SortimentItem? in
                let item = try? doc.data(as: SortimentItem.self)
                print("Načteno: \(String(describing: item))")
                return item
            }
        }
    }
}
