//
//  RegisterView.swift
//  DungeonStride
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    var onSwitchToLogin: () -> Void
    
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        AuthHeaderView(title: "Create Account", subtitle: "Join the adventure", icon: "person.badge.plus")
                            .padding(.top, 40)
                        
                        VStack(spacing: 16) {
                            AuthTextField(title: "Username", text: $authViewModel.username, isSecure: false)
                            AuthTextField(title: "Email", text: $authViewModel.email, isSecure: false)
                            AuthTextField(title: "Password", text: $authViewModel.password, isSecure: true)
                            AuthTextField(title: "Confirm Password", text: $confirmPassword, isSecure: true)
                        }
                        .padding(.horizontal)
                        
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        
                        AuthButton(title: "Create Account", isLoading: authViewModel.isLoading) {
                            register()
                        }
                        .disabled(!isFormValid || authViewModel.isLoading)
                        .opacity((!isFormValid || authViewModel.isLoading) ? 0.6 : 1.0)
                        
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(Color("Paleta4"))
                            Button("Sign In") { onSwitchToLogin() }
                                .foregroundColor(Color("Paleta2"))
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("Paleta2"))
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !authViewModel.email.isEmpty &&
        !authViewModel.password.isEmpty &&
        !confirmPassword.isEmpty &&
        !authViewModel.username.isEmpty &&
        authViewModel.password == confirmPassword &&
        authViewModel.password.count >= 6
    }
    
    private func register() {
        authViewModel.register()
    }
}
