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
                            // Zde musíme použít .rawValue, protože AuthTextField očekává String?
                            AuthTextField(title: "Username", placeholder: "Choose a username", text: $authViewModel.username, isSecure: false, testID: AccessibilityTag.registerUsernameField.rawValue)
                            
                            AuthTextField(title: "Email", placeholder: "Enter your email", text: $authViewModel.email, isSecure: false, testID: AccessibilityTag.registerEmailField.rawValue)
                            
                            AuthTextField(title: "Password", placeholder: "Create a password", text: $authViewModel.password, isSecure: true, testID: AccessibilityTag.registerPasswordField.rawValue)
                            
                            AuthTextField(title: "Confirm Password", placeholder: "Repeat password", text: $confirmPassword, isSecure: true, testID: AccessibilityTag.registerConfirmPasswordField.rawValue)
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
                        .accessibilityIdentifier(.registerButton) // <--- ZMĚNA
                        
                        HStack {
                            Text("Already have an account?", comment: "Register screen footer")
                                .foregroundColor(Color("Paleta4"))
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                onSwitchToLogin()
                            }) {
                                Text("Sign In", comment: "Link to login")
                                    .foregroundColor(Color("Paleta2"))
                                    .fontWeight(.semibold)
                            }
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
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(Color("Paleta2"))
                    }
                    .accessibilityIdentifier(.registerCancelButton) // <--- ZMĚNA
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