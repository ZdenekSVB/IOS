import SwiftUI
import PhotosUI

struct AEditSortimentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AEditSortimentViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Image URL") {
                    TextField("https://...", text: $viewModel.imageURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)

                    if let url = URL(string: viewModel.imageURL), !viewModel.imageURL.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 150)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Color.gray
                                    .frame(height: 150)
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }

                }

                Section("Basic Info") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                    TextField("Price", value: $viewModel.price, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Item" : "New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
