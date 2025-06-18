import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Paleta1").ignoresSafeArea()
                
                if authViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                } else {
                    VStack(spacing: 20) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.brown)
                            .padding(.bottom, 30)
                        
                        Text("Login")
                            .font(.largeTitle)
                            .bold()
                        
                        ClearableTextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .submitLabel(.go)
                            .onSubmit {
                                authViewModel.login(email: email, password: password)
                            }
                        
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Button("Log in") {
                            authViewModel.login(email: email, password: password)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Paleta2"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Don't have an account?")
                            NavigationLink(destination: RegisterView().navigationBarBackButtonHidden(true)) {
                                Text("Register")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ClearableTextField: View {
    let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 30)
            }
        }
    }
}
