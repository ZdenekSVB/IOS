// UsersView.swift
// CoffeeCozy

import SwiftUI
import Charts

struct AUsersView: View {
    @StateObject private var viewModel = AUsersViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.bottom, 8)

                // Login chart
                Chart(viewModel.loginData) { record in
                    LineMark(
                        x: .value("Date", record.date, unit: .day),
                        y: .value("Logins", record.count)
                    )
                    PointMark(
                        x: .value("Date", record.date, unit: .day),
                        y: .value("Logins", record.count)
                    )
                }
                .frame(height: 200)
                .padding(.horizontal)

                // User list with NavigationLink for edit
                List(viewModel.filteredUsers) { user in
                    NavigationLink {
                        EditUserView(viewModel: AEditUserViewModel(user: user))
                    } label: {
                        HStack {
                            Image(uiImage: user.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(user.username)
                                    .font(.headline)
                                Text("\(user.firstname) \(user.lastname)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                viewModel.delete(user)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
                .listStyle(.plain)

                Spacer()

                // Navbar placeholder at bottom
                Button("Navbar Placeholder") {
                    // placeholder action
                }
                .padding()
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .navigationTitle("Users")
            .toolbar {
                // "+" button to create a new user
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        EditUserView(viewModel: AEditUserViewModel())
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadUsers()
                viewModel.loadLoginData()
            }
        }
    }
}
