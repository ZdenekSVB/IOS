//
//  UserStatsChartView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 17.06.2025.
//


import SwiftUI
import Charts

struct UserStatsChartView: View {
    @ObservedObject var viewModel: AUsersViewModel

    var body: some View {
        Chart {
            ForEach(viewModel.userStats.sorted(by: { $0.date < $1.date })) { stat in
                BarMark(
                    x: .value("Datum", stat.date, unit: .day),
                    y: .value("Počet uživatelů", stat.count)
                )
                .foregroundStyle(Color.blue.gradient)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day().month())
            }
        }
        .chartYAxis {
            AxisMarks()
        }
    }
}
