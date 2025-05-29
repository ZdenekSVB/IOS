// EditUserView.swift
// CoffeeCozy

import SwiftUI
import PhotosUI

struct EditUserView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AEditUserViewModel

    var body: some View {
        NavigationView {
            Form {
                Section("Profile Image") {
                    if let img = viewModel.image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(8)
                    }
                    PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images) {
                        Text(viewModel.image == nil ? "Select Photo" : "Change Photo")
                    }
                }

                Section("User Info") {
                    TextField("Username", text: $viewModel.username)
                    TextField("First Name", text: $viewModel.firstname)
                    TextField("Last Name", text: $viewModel.lastname)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                    SecureField("Password", text: $viewModel.password)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit User" : "New User")
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
