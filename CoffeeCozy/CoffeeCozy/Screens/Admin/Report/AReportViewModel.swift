//
// AReportViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import Foundation
import FirebaseFirestore

class AReportViewModel: ObservableObject {
    @Published var entries: [ReportEntry] = []
    @Published var selectedCategory = ReportCategory.login

    var filteredEntries: [ReportEntry] {
        entries.filter { $0.category == selectedCategory }
    }

    func loadEntries() {
        Firestore.firestore()
            .collection("reports")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading reports: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                do {
                    self.entries = try documents.compactMap { try $0.data(as: ReportEntry.self) }
                } catch {
                    print("Error decoding report: \(error)")
                }
            }
    }
}
