//
//  DateFilterSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct DateFilterSection: View {
    @ObservedObject var viewModel: HistoryViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private let now = Date()
    
    var body: some View {
        VStack {
            // Tlačítko pro rozbalení
            Button(action: {
                withAnimation {
                    viewModel.isFilterExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(themeManager.accentColor)
                    Text("Filtrovat podle data")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    Spacer()
                    Image(systemName: viewModel.isFilterExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .padding()
                .background(themeManager.cardBackgroundColor)
            }
            
            // Rozbalovací část
            if viewModel.isFilterExpanded {
                VStack(spacing: 12) {
                    let maxStartDate = min(viewModel.filterEndDate, now)
                    
                    // DatePicker OD
                    datePickerRow(title: "Od:", selection: $viewModel.filterStartDate, range: ...maxStartDate)
                        .onChange(of: viewModel.filterStartDate) { _, newDate in
                            if newDate > viewModel.filterEndDate { viewModel.filterEndDate = newDate }
                        }
                    
                    let minEndDate = viewModel.filterStartDate
                    
                    // DatePicker DO
                    datePickerRow(title: "Do:", selection: $viewModel.filterEndDate, range: minEndDate...now)
                        .onChange(of: viewModel.filterEndDate) { _, newDate in
                            if newDate < viewModel.filterStartDate { viewModel.filterStartDate = newDate }
                        }
                    
                    // Reset Button
                    Button("Zobrazit vše (Reset)") {
                        if let oldest = viewModel.activities.last?.timestamp {
                            viewModel.filterStartDate = oldest
                        }
                        viewModel.filterEndDate = Date()
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.accentColor)
                    .padding(.top, 5)
                }
                .padding()
                .background(themeManager.cardBackgroundColor)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.1)),
                    alignment: .top
                )
            }
        }
        .cornerRadius(viewModel.isFilterExpanded ? 0 : 12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    // Helper pro DatePicker
    private func datePickerRow(title: String, selection: Binding<Date>, range: PartialRangeThrough<Date>) -> some View {
        DatePicker(title, selection: selection, in: range, displayedComponents: .date)
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
    
    // Helper pro DatePicker (ClosedRange)
    private func datePickerRow(title: String, selection: Binding<Date>, range: ClosedRange<Date>) -> some View {
        DatePicker(title, selection: selection, in: range, displayedComponents: .date)
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}
