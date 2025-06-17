//
//  RegisterView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.05.2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Paleta1").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 40)

                        Group {
                            clearableTextField("Username", text: $viewModel.username)
                            clearableTextField("First Name", text: $viewModel.firstName)
                            clearableTextField("Last Name", text: $viewModel.lastName)
                            clearableTextField("E-mail", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            clearableTextField("Phone Number", text: $viewModel.phone)
                                .keyboardType(.phonePad)
                            SecureField("Password", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }

                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        Button("Sign up") {
                            viewModel.register()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Paleta2"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(.horizontal)

                        HStack {
                            Text("Already have an account?")
                            Button("Sign in") {
                                viewModel.showingLogin = true
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.top)
                    }
                    .padding()
                }

                // Navigation for successful registration
                .navigationDestination(isPresented: $viewModel.isRegistered) {
                    RootTabView(isAdmin: false)
                }

                // Navigation to login view
                .navigationDestination(isPresented: $viewModel.showingLogin) {
                    LoginView().navigationBarBackButtonHidden(true)
                }
            }
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func clearableTextField(_ placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if !text.wrappedValue.isEmpty {
                Button(action: { text.wrappedValue = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 30)
            }
        }
    }
}
