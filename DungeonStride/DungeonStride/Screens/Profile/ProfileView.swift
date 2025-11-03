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
    @State private var showSettings = false
    @State private var selectedAvatar: String = "avatar1" // Default avatar
    @State private var photosPickerItem: PhotosPickerItem?
    
    // Předdefinované avatary
    let predefinedAvatars = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5"]
    
    // Level progress data
    let currentXP = 1250
    let xpForNextLevel = 2000
    
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
                            HStack {
                                Spacer()
                                
                                // Settings Button
                                Button(action: {
                                    showSettings = true
                                }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(Color("Paleta2"))
                                        .padding(8)
                                        .background(Color("Paleta5"))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                            
                            // Avatar s možností změny
                            Button(action: {
                                showAvatarPicker = true
                            }) {
                                ZStack {
                                    if selectedAvatar == "custom" {
                                        // Custom avatar z galerie
                                        if let customImage = loadCustomAvatar() {
                                            Image(uiImage: customImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                        } else {
                                            // Fallback placeholder
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(Color("Paleta4"))
                                        }
                                    } else {
                                        // Předdefinovaný avatar
                                        Image(selectedAvatar)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    }
                                    
                                    // Edit icon overlay - VIDITELNÝ
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            
                            // User Info
                            VStack(spacing: 12) {
                                Text(authViewModel.currentUserEmail ?? "User")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                // Level s Progress Bar
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Level 5")
                                            .font(.headline)
                                            .foregroundColor(Color("Paleta2"))
                                        
                                        Spacer()
                                        
                                        Text("\(currentXP)/\(xpForNextLevel) XP")
                                            .font(.caption)
                                            .foregroundColor(Color("Paleta4"))
                                    }
                                    
                                    // Progress Bar
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color("Paleta5"))
                                            .frame(height: 8)
                                            .cornerRadius(4)
                                        
                                        Rectangle()
                                            .fill(Color("Paleta2"))
                                            .frame(width: CGFloat(currentXP) / CGFloat(xpForNextLevel) * 300, height: 8)
                                            .cornerRadius(4)
                                    }
                                    .frame(width: 300)
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Stats Cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            StatCard(icon: "figure.walk", title: "Total Distance", value: "42.5 km")
                            StatCard(icon: "star.fill", title: "Total XP", value: "12,450")
                            StatCard(icon: "flag.fill", title: "Runs Completed", value: "28")
                            StatCard(icon: "trophy.fill", title: "Achievements", value: "15")
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {                            
                            Button("Logout") {
                                authViewModel.logout()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAvatarPicker) {
                AvatarSelectionView(
                    selectedAvatar: $selectedAvatar,
                    photosPickerItem: $photosPickerItem,
                    predefinedAvatars: predefinedAvatars
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
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
                            // Upload from Gallery option - VIDITELNÝ
                            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                ZStack {
                                    Circle()
                                        .fill(Color("Paleta5"))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Circle()
                                                .stroke(Color("Paleta2"), lineWidth: 2)
                                        )
                                    
                                    VStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(Color("Paleta2"))
                                        Text("Upload")
                                            .font(.caption)
                                            .foregroundColor(Color("Paleta2"))
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            
                            // Predefined avatars
                            ForEach(predefinedAvatars, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                    dismiss()
                                }) {
                                    ZStack {
                                        Image(avatar)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                        
                                        Circle()
                                            .stroke(selectedAvatar == avatar ? Color("Paleta2") : Color.clear, lineWidth: 3)
                                    }
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
                                if let customImage = loadCustomAvatar() {
                                    Image(uiImage: customImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color("Paleta4"))
                                }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
