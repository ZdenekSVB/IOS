import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AUsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var searchText: String = ""
    
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    
    // Spočítat uživatele podle data vytvoření (start dne)
    var userStats: [UserStat] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: users.compactMap { $0.createdAt }) {
            calendar.startOfDay(for: $0)
        }
        return grouped.map { (date, usersOnDay) in
            UserStat(date: date, count: usersOnDay.count)
        }
    }
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter {
                $0.username.localizedCaseInsensitiveContains(searchText) ||
                $0.firstname.localizedCaseInsensitiveContains(searchText) ||
                $0.lastname.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func loadUsers() {
        db.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading users: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No users found")
                return
            }
            
            self.users = documents.compactMap { doc -> User? in
                var user = try? doc.data(as: User.self)
                user?.id = doc.documentID
                return user
            }
        }
    }
    
    func delete(_ user: User) {
        guard let id = user.id else { return }
        
        db.collection("users").document(id).delete { error in
            if let error = error {
                print("Error deleting user from Firestore: \(error.localizedDescription)")
            } else {
                print("User deleted successfully from Firestore")
                
                if !user.email.isEmpty {
                    // Pozor: správné mazání uživatele v Auth může vyžadovat admin SDK
                    if let currentUser = self.auth.currentUser, currentUser.email == user.email {
                        currentUser.delete { error in
                            if let error = error {
                                print("Error deleting auth user: \(error.localizedDescription)")
                            } else {
                                print("User deleted from Authentication")
                            }
                        }
                    } else {
                        print("Nelze smazat uživatele z Authentication – není přihlášený")
                    }
                }
            }
        }
    }
    
    func updateUserRole(user: User, newRole: String) {
        guard let id = user.id else { return }
        
        var updatedUser = user
        updatedUser.role = newRole
        updatedUser.updatedAt = Date()
        
        do {
            try db.collection("users").document(id).setData(from: updatedUser, merge: true) { error in
                if let error = error {
                    print("Error updating user role: \(error.localizedDescription)")
                } else {
                    print("User role updated successfully")
                }
            }
        } catch {
            print("Error encoding user for update: \(error.localizedDescription)")
        }
    }
}
