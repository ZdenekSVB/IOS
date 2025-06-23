//
// AReportView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//
import SwiftUI

struct AReportView: View {
    @StateObject private var viewModel = AReportViewModel()

    var body: some View {
        NavigationStack {
            VStack {
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
            .toolbar { Toolbar() }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear(perform: viewModel.loadEntries)
        }
    }
}
