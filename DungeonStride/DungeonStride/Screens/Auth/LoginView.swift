//
//  LoginView.swift
//  DungeonStride
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3").ignoresSafeArea()
                
                VStack(spacing: 30) {
                    AuthHeaderView(title: "Welcome Back", icon: "person.crop.circle.fill")
                        .padding(.top, 60)
                    
                    VStack(spacing: 20) {
                        AuthTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $authViewModel.email,
                            isSecure: false
                        )
                        AuthTextField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $authViewModel.password,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal)
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    AuthButton(title: "Sign In", isLoading: authViewModel.isLoading) {
                        authViewModel.login()
                    }
                    .disabled(authViewModel.isLoading || authViewModel.email.isEmpty || authViewModel.password.isEmpty)
                    .opacity((authViewModel.isLoading || authViewModel.email.isEmpty || authViewModel.password.isEmpty) ? 0.6 : 1.0)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Text("Back")
                            .foregroundColor(Color("Paleta2"))
                    }
                    .accessibilityIdentifier(.loginBackButton) // <--- ZMĚNA
                }
            }
        }
    }
}