//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Image") {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            if let url = URL(string: viewModel.imageUrl), !viewModel.imageUrl.isEmpty {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 2))
                                            .shadow(radius: 4)
                                    case .failure:
                                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }

                            Text("Tap to Change Profile Image")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ProfileImagePicker(selectedImageUrl: $viewModel.imageUrl)
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
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear {
                viewModel.loadUserData()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                }
            }
            
        }
    }
}
