// UsersViewModel.swift
// CoffeeCozy

import SwiftUI

class AUsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var searchText: String = ""
    @Published var loginData: [LoginRecord] = []

    var filteredUsers: [User] {
        searchText.isEmpty
            ? users
            : users.filter {
                $0.username.localizedCaseInsensitiveContains(searchText) ||
                $0.firstname.localizedCaseInsensitiveContains(searchText) ||
                $0.lastname.localizedCaseInsensitiveContains(searchText)
            }
    }

    func loadUsers() {
        // TODO: fetch from Firestore
        users = [
            User(id: UUID(), username: "jsmith", lastname: "Smith", firstname: "John",
                 phoneNumber: "+420123456789", email: "john@example.com",
                 password: "••••••", image: UIImage(systemName: "person.circle")!),
            User(id: UUID(), username: "mjane", lastname: "Jane", firstname: "Mary",
                 phoneNumber: "+420987654321", email: "mary@example.com",
                 password: "••••••", image: UIImage(systemName: "person.circle.fill")!)
        ]
    }

    func loadLoginData() {
        let calendar = Calendar.current
        loginData = (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            return LoginRecord(date: date, count: Int.random(in: 0...20))
        }.sorted { $0.date < $1.date }
    }

    func delete(_ user: User) {
        // TODO: delete from Firestore
        users.removeAll { $0.id == user.id }
    }
}
