//
//  AReportViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// AReportViewModel.swift

import SwiftUI

class AReportViewModel: ObservableObject {
    @Published var entries: [ReportEntry] = []
    @Published var selectedCategory: ReportCategory = .login

    var filteredEntries: [ReportEntry] {
        entries.filter { $0.category == selectedCategory }
    }

    func loadEntries() {
        entries = [
            ReportEntry(category: .login,        message: "User John logged in",                    date: Date().addingTimeInterval(-3600)),
            ReportEntry(category: .registration, message: "User Mary registered",                     date: Date().addingTimeInterval(-7200)),
            ReportEntry(category: .deletion,     message: "User Mike deleted account",               date: Date().addingTimeInterval(-10800)),
            ReportEntry(category: .nameChange,   message: "User Adam changed name to AAdam",         date: Date().addingTimeInterval(-14400)),
            // ...další testovací záznamy
        ]
    }
}
