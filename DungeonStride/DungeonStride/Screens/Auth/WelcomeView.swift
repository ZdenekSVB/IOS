//
//  WelcomeView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI
import GoogleSignIn

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    @EnvironmentObject var authViewModel: AuthViewModel  // ← PŘIDEJ TUTO ŘÁDKU
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background s Paleta3
                Color("Paleta3")
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo and App Name
                    VStack(spacing: 20) {
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 360, height: 360)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Login Button
                        Button(action: {
                            showLogin = true
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .background(Color("Paleta2"))
                        .cornerRadius(12)
                        
                        
                        
                        // Google Login Button
                        Button(action: {
                            Task{
                                await authViewModel.signInWithGoogle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image("Google")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("Login with Google")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Color("Paleta3"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("Paleta4"), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(Color("Paleta4"))
                        
                        Button("Sign up") {
                            showRegister = true
                        }
                        .foregroundColor(Color("Paleta2"))
                        .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    // Footer text
                    Text("Embark on your adventure")
                        .font(.caption)
                        .foregroundColor(Color("Paleta4"))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showLogin) {
                LoginView()
            }
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView(onSwitchToLogin: {
                    showRegister = false
                    showLogin = true
                })
                .environmentObject(authViewModel)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
