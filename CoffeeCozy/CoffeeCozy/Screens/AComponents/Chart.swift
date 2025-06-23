//
//  Chart.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 20.06.2025.
//

import SwiftUI
import Charts


struct UserStatsChartView: View {
    @ObservedObject var viewModel: AUsersViewModel

    var body: some View {
        VStack(alignment: .leading) {
            let sortedStats = viewModel.userStats.sorted { $0.date < $1.date }
            let maxY = max(1, sortedStats.map(\.count).max() ?? 1)

            Chart(sortedStats) { stat in
                LineMark(
                    x: .value("Datum", stat.date),
                    y: .value("Počet", stat.count)
                )
                .interpolationMethod(.catmullRom) // hladká křivka
                .foregroundStyle(Color.green)
                // .symbol(Circle()) // odstraněno, aby nebyly kolečka
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                }
            }
            .chartYScale(domain: 0...maxY)
            .frame(height: 200)
        }
    }
}

struct OrderRevenueChartView: View {
    let orders: [OrderRecord]

    var body: some View {
        let finishedOrders = orders.filter { $0.status == "finished" }
        let revenuePerDay = calculateRevenuePerDay(orders: finishedOrders)
        let maxY = max(1, revenuePerDay.map(\.1).max() ?? 1)

        VStack(alignment: .leading) {
            Chart {
                ForEach(revenuePerDay, id: \.0) { (date, total) in
                    LineMark(
                        x: .value("Datum", date),
                        y: .value("Tržba", total)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                    // .symbol(Circle()) // odstraněno
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                }
            }
            .chartYScale(domain: 0...maxY)
            .frame(height: 200)
        }
        .padding(.vertical)
    }

    private func calculateRevenuePerDay(orders: [OrderRecord]) -> [(Date, Double)] {
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
