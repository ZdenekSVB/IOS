import SwiftUI

struct AEditUserView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AEditUserViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Image URL") {
                    TextField("https://...", text: $viewModel.imageUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)

                    if let url = URL(string: viewModel.imageUrl), !viewModel.imageUrl.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(height: 150)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(8)
                            case .failure:
                                Color.gray.frame(height: 150).cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }

                Section("User Info") {
                    TextField("Username", text: $viewModel.username)
                    TextField("First Name", text: $viewModel.firstname)
                    TextField("Last Name", text: $viewModel.lastname)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                    SecureField("Password", text: $viewModel.password)

                    Picker("Role", selection: $viewModel.role) {
                        Text("User").tag("user")
                        Text("Admin").tag("admin")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit User" : "New User")
            .toolbar {
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
