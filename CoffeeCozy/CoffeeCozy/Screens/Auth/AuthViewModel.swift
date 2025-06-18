import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var isLoggedIn = false
    @Published var isAdmin = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private init() {}
    
    func login(email: String, password: String) {
        
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let user = result?.user else {
                    self?.errorMessage = "Login failed"
                    return
                }
                
                ReportLogger.log(.login, message: "User \(email) logged in")
                self?.fetchUserRole(uid: user.uid)
            }
        }
    }
    
    func logout() {
        do {
            if let email = Auth.auth().currentUser?.email {
                ReportLogger.log(.logout, message: "User \(email) logged out")
            }
            try Auth.auth().signOut()
            isLoggedIn = false
            isAdmin = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    
    private func fetchUserRole(uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = snapshot?.data(),
                      let role = data["role"] as? String else {
                    self?.isAdmin = false
                    self?.isLoggedIn = true
                    return
                }
                
                self?.isAdmin = role == "admin"
                self?.isLoggedIn = true
            }
        }
    }
}
