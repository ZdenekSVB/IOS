//  RegistrationView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.05.2025.
//
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Registration")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    
                    Group {
                        TextField("Username", text: $viewModel.username)
                        TextField("Firstname", text: $viewModel.firstName)
                        TextField("Lastname", text: $viewModel.lastName)
                        TextField("E-mail", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Phone Number", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                        SecureField("Password", text: $viewModel.password)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button("Sign up") {
                        viewModel.register()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Already have an account")
                        Button("Sign in") {
                            viewModel.showingLogin = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.top)
                    
                    NavigationLink(destination: ContentView(), isActive: $viewModel.isRegistered) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: LoginView(), isActive: $viewModel.showingLogin) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
