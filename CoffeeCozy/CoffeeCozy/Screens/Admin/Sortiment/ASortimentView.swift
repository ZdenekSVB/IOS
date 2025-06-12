
//  ASortimentView.swift
//  CoffeeCozy

import SwiftUI

struct ASortimentView: View {
    @StateObject private var viewModel = ASortimentViewModel()
    @State private var selectedItem: SortimentItem?
    @State private var editNew = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $viewModel.searchText)

                let items = viewModel.filteredItems

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(items) { item in
                            VStack {
                                SortimentTile(item: item)
                            }
                            .onTapGesture {
                                selectedItem = item
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .navigationTitle("Sortiment")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedItem = nil
                        editNew = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: item.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(height: 180)
                        case .success(let img):
                            img.resizable()
                               .scaledToFit()
                               .frame(height: 180)
                               .cornerRadius(12)
                        case .failure:
                            Color.gray.frame(height: 180).cornerRadius(12)
                        @unknown default:
                            EmptyView()
                        }
                    }

                    Text(item.name).font(.title2).bold()
                    Text(item.desc).font(.body).padding(.horizontal)
                    Text(String(format: "%.2f Kč", item.price)).font(.title3)
                    Button("Zavřít") { selectedItem = nil }.padding()
                }
                .padding()
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $editNew) {
                AEditSortimentView(viewModel: AEditSortimentViewModel())
            }
        }
    }
}
