//
//  ProfileImagePicker.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.06.2025.
//


import SwiftUI
import FirebaseFirestore

struct ProfileImagePicker: View {
    @Binding var selectedImageUrl: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var imageUrls: [String] = []
    @State private var showUrlInput = false
    @State private var customUrl: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    Button(action: {
                        showUrlInput.toggle()
                    }) {
                        VStack {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                            Text("Custom URL")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    ForEach(imageUrls, id: \.self) { url in
                        Button(action: {
                            selectedImageUrl = url
                            dismiss()
                        }) {
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable()
                                     .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        }
                    }
                }
                .padding()
                
                if showUrlInput {
                    VStack(alignment: .leading) {
                        Text("Enter Custom URL:")
                            .font(.headline)
                        TextField("https://...", text: $customUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.URL)

                        Button("Use This URL") {
                            selectedImageUrl = customUrl
                            dismiss()
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Image")
            .onAppear(perform: loadImages)
        }
    }
    
    func loadImages() {
        let db = Firestore.firestore()
        db.collection("images").getDocuments { snapshot, error in
            if let error = error {
                print("Failed to load images: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            imageUrls = documents.compactMap { $0.data()["imageURL"] as? String }
        }
    }
}
