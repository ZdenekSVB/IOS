//  LoginView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.05.2025.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.brown)
                    .padding(.bottom, 30)
                
                Text("Přihlášení")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                SecureField("Heslo", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button("Přihlásit se") {
                    viewModel.login()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                HStack {
                    Text("Nemáte účet?")
                    Button("Vytvořit nový účet") {
                        viewModel.showingRegistration = true
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top)
                
                NavigationLink(destination: ContentView(), isActive: $viewModel.isLoggedIn) {
                    EmptyView()
                }
                
                NavigationLink(destination: RegisterView(), isActive: $viewModel.showingRegistration) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}
