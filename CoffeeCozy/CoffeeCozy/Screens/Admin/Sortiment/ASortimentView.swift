import SwiftUI

struct ASortimentView: View {
    @StateObject private var viewModel = ASortimentViewModel()
    @State private var selectedItem: SortimentItem?
    @State private var editNew = false
    @State private var editItem: SortimentItem?

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
                                onEdit: { editItem = item },
                                onTap: { selectedItem = item }
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .navigationTitle("Sortiment")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                SortimentDetail(item: item)
            }
            .sheet(isPresented: $editNew) {
                AEditSortimentView(viewModel: AEditSortimentViewModel())
            }
            .sheet(item: $editItem) { item in
                AEditSortimentView(viewModel: AEditSortimentViewModel(item: item))
            }
        }
    }
}
