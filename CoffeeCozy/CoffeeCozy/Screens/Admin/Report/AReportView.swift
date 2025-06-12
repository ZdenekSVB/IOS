// AReportView.swift
// CoffeeCozy

import SwiftUI

struct AReportView: View {
    @StateObject private var viewModel = AReportViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Dropdown menu for selecting category
                Menu {
                    ForEach(ReportCategory.allCases) { category in
                        Button(category.rawValue) {
                            viewModel.selectedCategory = category
                        }
                    }
                } label: {
                    Label(viewModel.selectedCategory.rawValue, systemImage: "chevron.down")
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding()

                // List of filtered report entries
                List(viewModel.filteredEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.message)
                            .foregroundColor(.black)
                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.white)
                }
                .listStyle(.plain)
                .background(Color.white)

            }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear {
                viewModel.loadEntries()
            }
        }
    }
}
