//
//  ProfileView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAvatarPicker = false
    @State private var selectedAvatar: String = "avatar1" // Default avatar
    @State private var photosPickerItem: PhotosPickerItem?
    
    // Předdefinované avatary
    let predefinedAvatars = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color("Paleta3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Header
                        VStack(spacing: 20) {
                            // Avatar s možností změny
                            Button(action: {
                                showAvatarPicker = true
                            }) {
                                ZStack {
                                    if selectedAvatar == "custom" {
                                        // Custom avatar z galerie
                                        Image(uiImage: loadCustomAvatar() ?? UIImage(systemName: "person.crop.circle.fill")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } else {
                                        // Předdefinovaný avatar
                                        Image(selectedAvatar)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    }
                                    
                                    // Edit icon overlay
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                        )
                                        .opacity(0)
                                }
                            }
                            
                            // User Info
                            VStack(spacing: 8) {
                                Text(authViewModel.currentUserEmail ?? "User")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Level 5 Adventurer")
                                    .font(.subheadline)
                                    .foregroundColor(Color("Paleta2"))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats Cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            StatCard(icon: "figure.walk", title: "Total Distance", value: "42.5 km")
                            StatCard(icon: "star.fill", title: "Total XP", value: "12,450")
                            StatCard(icon: "flag.fill", title: "Runs Completed", value: "28")
                            StatCard(icon: "trophy.fill", title: "Achievements", value: "15")
                        }
                        .padding(.horizontal)
                        
                        // Logout Button
                        Button("Logout") {
                            authViewModel.logout()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Profile")
            .sheet(isPresented: $showAvatarPicker) {
                AvatarSelectionView(
                    selectedAvatar: $selectedAvatar,
                    photosPickerItem: $photosPickerItem,
                    predefinedAvatars: predefinedAvatars
                )
            }
            .onChange(of: photosPickerItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        saveCustomAvatar(image)
                        selectedAvatar = "custom"
                    }
                }
            }
        }
    }
    
    private func loadCustomAvatar() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: "customAvatar") else { return nil }
        return UIImage(data: data)
    }
    
    private func saveCustomAvatar(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        UserDefaults.standard.set(data, forKey: "customAvatar")
    }
}

// MARK: - Avatar Selection View
struct AvatarSelectionView: View {
    @Binding var selectedAvatar: String
    @Binding var photosPickerItem: PhotosPickerItem?
    let predefinedAvatars: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Choose Your Avatar")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                            // Upload from Gallery option
                            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                ZStack {
                                    Circle()
                                        .fill(Color("Paleta5"))
                                        .frame(width: 80, height: 80)
                                    
                                    VStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(Color("Paleta2"))
                                        Text("Upload")
                                            .font(.caption)
                                            .foregroundColor(Color("Paleta4"))
                                    }
                                }
                            }
                            
                            // Predefined avatars
                            ForEach(predefinedAvatars, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                    dismiss()
                                }) {
                                    Image(avatar)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedAvatar == avatar ? Color("Paleta2") : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Current selection preview
                        VStack(spacing: 12) {
                            Text("Current Selection")
                                .font(.headline)
                                .foregroundColor(Color("Paleta4"))
                            
                            if selectedAvatar == "custom" {
                                Image(uiImage: loadCustomAvatar() ?? UIImage(systemName: "person.circle.fill")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(selectedAvatar)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color("Paleta5"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Select Avatar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("Paleta2"))
                }
            }
        }
    }
    
    private func loadCustomAvatar() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: "customAvatar") else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Stat Card (zůstává stejné)
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("Paleta2"))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color("Paleta4"))
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
