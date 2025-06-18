import Foundation
import FirebaseFirestore

class ASortimentViewModel: ObservableObject {
    @Published var items: [SortimentItem] = []
    @Published var searchText = ""

    private var db = Firestore.firestore()

    init() {
        fetchItems()
    }

    func fetchItems() {
        db.collection("sortiment").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Chyba při načítání (admin): \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Žádná data v sortimentu (admin)")
                return
            }

            self.items = documents.compactMap { doc -> SortimentItem? in
                let item = try? doc.data(as: SortimentItem.self)
                print("Načteno (admin): \(String(describing: item))")
                return item
            }
        }
    }

    var filteredItems: [SortimentItem] {
        searchText.isEmpty
            ? items
            : items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    func deleteItem(_ item: SortimentItem) {
        guard let id = item.id else { return }

        db.collection("sortiment").document(id).delete { error in
            if let error = error {
                print("Chyba při mazání: \(error.localizedDescription)")
            } else {
                print("Položka smazána")
                ReportLogger.log(.deletion, message: "Item deleted: \(item.name) (ID: \(id))")
            }
        }
    }


}
