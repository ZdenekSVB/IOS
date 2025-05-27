//
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

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Přihlášení / Registrace")
                    .font(.largeTitle)

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

                Button("Registrovat") {
                    register()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Přihlásit se") {
                    login()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink(destination: ContentView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Chyba při registraci: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
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
