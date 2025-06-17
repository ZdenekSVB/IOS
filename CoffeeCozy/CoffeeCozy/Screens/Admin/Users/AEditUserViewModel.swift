import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AEditUserViewModel: ObservableObject {
    @Published var username = ""
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var password = "" // Používá se jen při registraci
    @Published var imageUrl = ""
    @Published var role = "user"

    private let db = Firestore.firestore()
    private var existingUserId: String?
    private var createdAt: Date?

    var isEditing: Bool {
        existingUserId != nil
    }

    init(user: User? = nil) {
        if let user = user {
            self.username = user.username
            self.firstname = user.firstname
            self.lastname = user.lastname
            self.phoneNumber = user.phoneNumber
            self.email = user.email
            self.imageUrl = user.imageUrl ?? ""
            self.role = user.role
            self.existingUserId = user.id
            self.createdAt = user.createdAt
        }
    }

    var isValid: Bool {
        !username.isEmpty &&
        !firstname.isEmpty &&
        !lastname.isEmpty &&
        !email.isEmpty &&
        (!isEditing || !password.isEmpty)
    }

    func save() {
        let now = Date()
        let userData: [String: Any] = [
            "username": username,
            "firstname": firstname,
            "lastname": lastname,
            "phoneNumber": phoneNumber,
            "email": email,
            "imageUrl": imageUrl,
            "role": role,
            "updatedAt": Timestamp(date: now),
            "createdAt": Timestamp(date: createdAt ?? now)
        ]

        if let id = existingUserId {
            // Update existujícího uživatele v databázi
            db.collection("users").document(id).setData(userData, merge: true) { error in
                if let error = error {
                    print("Chyba při aktualizaci uživatele: \(error.localizedDescription)")
                } else {
                    print("Uživatel aktualizován")
                }
            }
        } else {
            // Vytvoření nového uživatele – pouze Auth obsahuje heslo
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Chyba při registraci uživatele v Auth: \(error.localizedDescription)")
                    return
                }

                guard let uid = result?.user.uid else { return }

                // Firestore – bez hesla
                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        print("Chyba při ukládání do Firestore: \(error.localizedDescription)")
                    } else {
                        print("Nový uživatel úspěšně vytvořen")
                    }
                }
            }
        }
    }
}
