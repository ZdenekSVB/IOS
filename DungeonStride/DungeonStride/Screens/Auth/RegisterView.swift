import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    var onSwitchToLogin: () -> Void  // ← PŘIDEJ TUTO ŘÁDKU
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background s Paleta3
                Color("Paleta3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(Color("Paleta2"))
                            
                            Text("Create Account")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Join the adventure")
                                .font(.subheadline)
                                .foregroundColor(Color("Paleta4"))
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Enter your username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.never)
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Error Message
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Register Button
                        Button(action: register) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(Color("Paleta2"))
                        .cornerRadius(12)
                        .disabled(authViewModel.isLoading || !isFormValid)
                        .opacity((authViewModel.isLoading || !isFormValid) ? 0.6 : 1.0)
                        .padding(.horizontal)
                        
                        // Login Link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(Color("Paleta4"))
                            
                            Button("Sign In") {
                                onSwitchToLogin()  // ← ZMĚŇ dismiss() NA TOTO
                            }
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
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("Paleta2"))
                }
            }
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !username.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        email.contains("@") &&
        email.contains(".")
    }
    
    private func register() {
        guard isFormValid else {
            authViewModel.errorMessage = "Please fill all fields correctly"
            return
        }
        
        // Set values in ViewModel
        authViewModel.email = email
        authViewModel.password = password
        authViewModel.username = username
        
        authViewModel.register()
    }
}
