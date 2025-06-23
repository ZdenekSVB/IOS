//
//  ASortimentView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI

struct ASortimentView: View {
    @StateObject private var viewModel = ASortimentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedItem: SortimentItem?
    @State private var editNew = false
    @State private var editItem: SortimentItem?

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $viewModel.searchText)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredItems) { item in
                            SortimentTile(
                                item: item,
                                isAdmin: true,
                                onEdit: { editItem = item },
                                onDelete: { viewModel.deleteItem(item) },
                                onAddToCart: {},
                                onTap: { selectedItem = item }
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .toolbar {
                Toolbar()
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { editNew = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedItem) { SortimentDetail(item: $0) }
            .sheet(isPresented: $editNew) { AEditSortimentView(viewModel: AEditSortimentViewModel()) }
            .sheet(item: $editItem) { AEditSortimentView(viewModel: AEditSortimentViewModel(item: $0)) }
        }
    }
}
