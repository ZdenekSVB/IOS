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
                    Text("Registrace")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    
                    Group {
                        TextField("Jméno", text: $viewModel.firstName)
                        TextField("Příjmení", text: $viewModel.lastName)
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Telefon", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                        SecureField("Heslo", text: $viewModel.password)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button("Registrovat") {
                        viewModel.register()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Již máte účet?")
                        Button("Přihlásit se") {
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
