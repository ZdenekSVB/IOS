//
//  ASortimentView.swift
//  CoffeeCozy
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

                let items = viewModel.filteredItems

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(items) { item in
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
                AdminToolbar()
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { editNew = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // DETAIL
            .sheet(item: $selectedItem) { item in
                SortimentDetail(item: item)
            }
            // NOVÝ
            .sheet(isPresented: $editNew) {
                AEditSortimentView(viewModel: AEditSortimentViewModel())
            }
            // EDITACE
            .sheet(item: $editItem) { item in
                AEditSortimentView(viewModel: AEditSortimentViewModel(item: item))
            }
        }
    }
}
