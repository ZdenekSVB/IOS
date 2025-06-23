//
//  Chart.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 20.06.2025.
//

import SwiftUI
import Charts

protocol ChartDataPoint: Identifiable {
    var date: Date { get }
    var value: Double { get }
}
struct GenericChartDataPoint: ChartDataPoint {
    let id = UUID()
    let date: Date
    let value: Double
}
struct GenericChartView<T: ChartDataPoint>: View {
    var dataPoints: [T]
    var lineColor: Color
    var pointColor: Color
    var annotationSuffix: String

    @State private var selectedPoint: T? = nil

    var body: some View {
        let sortedPoints = dataPoints.sorted { $0.date < $1.date }
        let maxY = max(1, sortedPoints.map(\.value).max() ?? 1)

        VStack(alignment: .leading) {
            Chart(sortedPoints) { point in
                LineMark(
                    x: .value("Datum", point.date),
                    y: .value("Hodnota", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(lineColor)

                if selectedPoint?.id == point.id {
                    RuleMark(x: .value("Datum", point.date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(pointColor.opacity(0.6))

                    PointMark(
                        x: .value("Datum", point.date),
                        y: .value("Hodnota", point.value)
                    )
                    .foregroundStyle(pointColor)
                    .annotation(position: .top, alignment: .center) {
                        Text(String(format: "%.0f %@", point.value, annotationSuffix))
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(6)
                            .background(Color.white)
                            .cornerRadius(6)
                            .shadow(radius: 3)
                    }
                }
            }

            .chartXAxis {
                AxisMarks(values: sortedPoints.map { $0.date }) { value in
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(date, format: Date.FormatStyle().day().month())
                        }
                    }
                    AxisTick()
                    AxisGridLine()
                }
            }
            
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let doubleValue = value.as(Double.self), doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                        AxisValueLabel("\(Int(doubleValue))")
                        AxisTick()
                        AxisGridLine()
                    } else {
                        AxisTick()
                        AxisGridLine()
                    }
                }
            }


            .chartYScale(domain: 0...maxY)
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    if let date: Date = proxy.value(atX: location.x) {
                                        let nearest = sortedPoints.min(by: {
                                            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                        })
                                        selectedPoint = nearest
                                    }
                                }
                        )
                }
            }
        }
    }
}
