//
//  WelcomeView.swift
//  DungeonStride
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3").ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo logic...
                    if let logoImage = UIImage(named: "AppLogo") {
                        Image(uiImage: logoImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 280, height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("Paleta2"))
                            .frame(width: 150, height: 150)
                            .overlay(Text("LOGO").foregroundColor(.white).bold())
                    }
                    
                    VStack(spacing: 16) {
                        WelcomeButton(title: "Login", icon: "person.fill", color: Color("Paleta2")) {
                            showLogin = true
                        }
                        .accessibilityIdentifier(.welcomeLoginButton) // <--- ZMĚNA
                        
                        WelcomeButton(title: "Login with Google", icon: "globe", isSystemImage: true, color: .white, textColor: .black) {
                            Task { authViewModel.signInWithGoogle() }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    HStack {
                        Text("Don't have an account?", comment: "Welcome screen footer text")
                            .foregroundColor(Color("Paleta4"))
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showRegister = true
                        }) {
                            Text("Sign up", comment: "Link to registration")
                                .foregroundColor(Color("Paleta2"))
                                .fontWeight(.semibold)
                        }
                        .accessibilityIdentifier(.welcomeSignUpButton) // <--- ZMĚNA
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showLogin) { LoginView() }
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView(onSwitchToLogin: {
                    showRegister = false
                    showLogin = true
                })
            }
        }
    }
}