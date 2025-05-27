//  LoginView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.05.2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage = ""
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App icon
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.brown)
                    .padding(.bottom, 30)
                
                Text("Přihlášení")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                SecureField("Heslo", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button("Přihlásit se") {
                    login()
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
                        showingRegistration = true
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top)
                
                NavigationLink(destination: ContentView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
                
                NavigationLink(destination: RegistrationView(), isActive: $showingRegistration) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Chyba při přihlášení: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
        }
    }
}
