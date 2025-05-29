//
//  AOrdersViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// AOrdersViewModel.swift
// CoffeeCozy

import SwiftUI

class AOrdersViewModel: ObservableObject {
    @Published var orders: [OrderRecord] = []
    @Published var orderCounts: [OrderCount] = []
    @Published var searchText: String = ""

    var filteredOrders: [OrderRecord] {
        searchText.isEmpty
            ? orders
            : orders.filter { $0.userName.localizedCaseInsensitiveContains(searchText) }
    }

    func loadOrders() {
        let calendar = Calendar.current
        let today = Date()

        // Sample data
        orders = [
            OrderRecord(id: UUID(), userName: "Alice",   date: calendar.date(byAdding: .day, value: -3, to: today)!, total: 55.99),
            OrderRecord(id: UUID(), userName: "Bob",     date: calendar.date(byAdding: .day, value: -2, to: today)!, total: 120.0),
            OrderRecord(id: UUID(), userName: "Charlie", date: calendar.date(byAdding: .day, value: -2, to: today)!, total: 75.50),
            OrderRecord(id: UUID(), userName: "Diana",   date: calendar.date(byAdding: .day, value: -1, to: today)!, total: 34.20),
            OrderRecord(id: UUID(), userName: "Eve",     date: today,                                             total: 99.00)
        ]

        // Aggregate counts per day
        let grouped = Dictionary(grouping: orders) {
            calendar.startOfDay(for: $0.date)
        }
        orderCounts = grouped.map { OrderCount(date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }
}
