//
//  OrderRevenueChartView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//


import SwiftUI
import Charts

struct OrderRevenueChartView: View {
    let orders: [OrderRecord]

    var body: some View {
        let revenuePerDay = calculateRevenuePerDay()

        Chart {
            ForEach(revenuePerDay, id: \.0) { (date, total) in
                BarMark(
                    x: .value("Date", date, unit: .day),
                    y: .value("Revenue", total)
                )
                .foregroundStyle(.green)
            }
        }
        .frame(height: 200)
        .padding(.vertical)
    }

    private func calculateRevenuePerDay() -> [(Date, Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: orders) {
            calendar.startOfDay(for: $0.createdAt)
        }

        return grouped.map { (date, orders) in
            let total = orders.reduce(0) { $0 + $1.totalPrice }
            return (date, total)
        }.sorted { $0.0 < $1.0 }
    }
}
