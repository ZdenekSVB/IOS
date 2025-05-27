//  RegistrationView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.05.2025.
//

import SwiftUI
import FirebaseAuth

struct RegistrationView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var isRegistered = false
    @State private var errorMessage = ""
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Registrace")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    
                    Group {
                        TextField("Jméno", text: $firstName)
                        TextField("Příjmení", text: $lastName)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Telefon", text: $phone)
                            .keyboardType(.phonePad)
                        SecureField("Heslo", text: $password)
                    }
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
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Již máte účet?")
                        Button("Přihlásit se") {
                            showingLogin = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.top)
                    
                    NavigationLink(destination: ContentView(), isActive: $isRegistered) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: LoginView(), isActive: $showingLogin) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Chyba při registraci: \(error.localizedDescription)"
            } else {
                // Here you would typically also save the additional user data (firstName, lastName, phone)
                // to Firestore or Realtime Database
                isRegistered = true
            }
        }
    }
}
