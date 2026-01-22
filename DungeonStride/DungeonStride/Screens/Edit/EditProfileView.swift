////
//  EditProfileView.swift
//  DungeonStride
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: EditProfileViewModel
    
    @State private var showAvatarPicker = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // --- ZMĚNA AVATARA ---
                    VStack(spacing: 10) {
                        Button(action: {
                            showAvatarPicker = true
                        }) {
                            ZStack {
                                Image(viewModel.selectedAvatar == "default" ? "default" : viewModel.selectedAvatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(themeManager.accentColor, lineWidth: 3)
                                    )
                                    .shadow(radius: 5)
                                
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(themeManager.accentColor))
                                    .offset(x: 40, y: 40)
                            }
                        }
                        
                        Text("Změnit avatara")
                            .font(.caption)
                            .foregroundColor(themeManager.accentColor)
                    }
                    .padding(.top, 20)
                    
                    // --- FORMULÁŘ ---
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Username Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("UŽIVATELSKÉ JMÉNO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            TextField("Zadejte jméno", text: $viewModel.username)
                                .padding()
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.primaryTextColor)
                        }
                        
                        // Email (Read-only)
                        // TADY JE OPRAVA: Zobrazuje jen email, žádné placeholdery
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EMAIL (Nelze změnit)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            // Používáme Text místo TextField, aby to nešlo editovat
                            Text(viewModel.email)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading) // Zarovnání doleva
                                .background(themeManager.cardBackgroundColor.opacity(0.5)) // Trochu průhlednější pozadí (disabled look)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.secondaryTextColor) // Šedá barva textu
                        }
                        
                        Divider()
                            .background(themeManager.secondaryTextColor)
                            .padding(.vertical, 10)
                        
                        // --- SEKCE ZMĚNA HESLA ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ZMĚNA HESLA (VOLITELNÉ)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            // Staré heslo
                            SecureField("Stávající heslo (pro potvrzení)", text: $viewModel.oldPassword)
                                .padding()
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.primaryTextColor)
                            
                            // Nové heslo
                            SecureField("Nové heslo", text: $viewModel.newPassword)
                                .padding()
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.primaryTextColor)
                            
                            // Potvrzení hesla
                            SecureField("Potvrzení nového hesla", text: $viewModel.confirmNewPassword)
                                .padding()
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(12)
                                .foregroundColor(themeManager.primaryTextColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.saveChanges()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Uložit změny")
                                .bold()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: themeManager.accentColor))
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .navigationTitle("Upravit profil")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerSheet(selectedAvatar: $viewModel.selectedAvatar)
                .environmentObject(themeManager)
        }
        .onChange(of: viewModel.saveSuccess) { _, success in
            if success {
                dismiss()
            }
        }
    }
}
// --- NOVÁ KOMPONENTA PRO VÝBĚR (GRID) ---
struct AvatarPickerSheet: View {
    @Binding var selectedAvatar: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    // Seznam názvů obrázků (ujistěte se, že je máte v Assets.xcassets)
    let avatars = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6"]
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Vyberte si hrdinu")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                    .padding(.top, 20)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(avatars, id: \.self) { avatarName in
                            Button(action: {
                                selectedAvatar = avatarName
                                dismiss() // Zavřít okno po výběru
                            }) {
                                Image(avatarName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(themeManager.accentColor, lineWidth: selectedAvatar == avatarName ? 4 : 0)
                                    )
                                    .shadow(radius: 3)
                            }
                        }
                    }
                    .padding()
                }
                
                Button("Zrušit") {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.medium, .large]) // iOS 16+ (Poloviční okno)
        .presentationDragIndicator(.visible)
    }
}
