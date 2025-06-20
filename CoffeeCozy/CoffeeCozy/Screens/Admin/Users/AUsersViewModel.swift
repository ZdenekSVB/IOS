//
//  AUsersViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AUsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var searchText = ""

    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    var userStats: [UserStat] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: users.compactMap { $0.createdAt }) {
            calendar.startOfDay(for: $0)
        }
        return grouped.map { UserStat(date: $0.key, count: $0.value.count) }
    }

    var filteredUsers: [User] {
        guard !searchText.isEmpty else { return users }
        return users.filter {
            $0.username.localizedCaseInsensitiveContains(searchText) ||
            $0.firstname.localizedCaseInsensitiveContains(searchText) ||
            $0.lastname.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadUsers() {
        db.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading users: \(error.localizedDescription)")
                return
            }

            self.users = snapshot?.documents.compactMap { doc in
                var user = try? doc.data(as: User.self)
                user?.id = doc.documentID
                return user
            } ?? []
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
                    if let currentUser = self.auth.currentUser, currentUser.email == user.email {
                        currentUser.delete { error in
                            if let error = error {
                                print("Error deleting auth user: \(error.localizedDescription)")
                            } else {
                                print("User deleted from Authentication")
                                ReportLogger.log(.deletion, message: "User deleted: \(user.username) (\(user.email))")
                            }
                        }
                    } else {
                        print("Cannot delete user from Authentication – not logged in as that user")
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
