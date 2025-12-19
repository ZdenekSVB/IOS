//
//  WelcomeView.swift
//  DungeonStride
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = WelcomeViewModel()
    
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3").ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 16) {
                        WelcomeButton(title: "Login", icon: "person.fill", color: Color("Paleta2")) {
                            showLogin = true
                        }
                        
                        WelcomeButton(title: "Login with Google", icon: "Google", isSystemImage: false, color: .white, textColor: .black) {
                            Task { await authViewModel.signInWithGoogle() }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(Color("Paleta4"))
                        Button("Sign up") { showRegister = true }
                            .foregroundColor(Color("Paleta2"))
                            .fontWeight(.semibold)
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
