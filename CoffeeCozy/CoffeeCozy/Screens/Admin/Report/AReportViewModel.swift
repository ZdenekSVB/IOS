import Foundation
import FirebaseFirestore

class AReportViewModel: ObservableObject {
    @Published var entries: [ReportEntry] = []
    @Published var selectedCategory: ReportCategory = .login

    var filteredEntries: [ReportEntry] {
        entries.filter { $0.category == selectedCategory }
    }

    func loadEntries() {
        let db = Firestore.firestore()

        db.collection("reports")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading reports: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                do {
                    self.entries = try documents.compactMap { doc in
                        try doc.data(as: ReportEntry.self)
                    }
                } catch {
                    print("Error decoding report: \(error)")
                }
            }
    }
}
