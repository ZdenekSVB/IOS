import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Paleta1").ignoresSafeArea()
                
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
                    
                    clearableTextField("Email", text: $viewModel.email)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button("Log in") {
                        viewModel.login()
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
            .navigationDestination(isPresented: Binding<Bool>(get: {viewModel.isLoggedIn && viewModel.isAdmin}, set: { _ in })){
                ASortimentView()
            }
            .navigationDestination(isPresented:  Binding<Bool>(get: {viewModel.isLoggedIn && !viewModel.isAdmin}, set: { _ in })){
                HomeView()
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
