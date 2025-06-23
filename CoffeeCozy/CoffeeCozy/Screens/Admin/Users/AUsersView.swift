//
//  AUsersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI

struct AUsersView: View {
    @StateObject private var viewModel = AUsersViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText)
                    .padding(.vertical, 8)
                    .padding(.horizontal)

                UserStatsChartView(viewModel: viewModel)
                    .padding(.horizontal)

                UserListView(users: viewModel.filteredUsers, deleteAction: viewModel.delete)
            }
            .toolbar {
                Toolbar()
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AEditUserView(viewModel: AEditUserViewModel())
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear { viewModel.loadUsers() }
        }
    }
}

struct UserListView: View {
    let users: [User]
    let deleteAction: (User) -> Void

    var body: some View {
        List {
            ForEach(users) { user in
                HStack {
                    NavigationLink {
                        AEditUserView(viewModel: AEditUserViewModel(user: user))
                    } label: {
                        UserRow(user: user)
                    }
                    Spacer()
                    Button(role: .destructive) { deleteAction(user) }
                    label: { Image(systemName: "trash") }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        HStack {
            if let imageUrl = user.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView().frame(width: 40, height: 40)
                    case .success(let image):
                        image.resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .foregroundStyle(.gray)
                    @unknown default: EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundStyle(.gray)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.username).font(.headline)
                Text("\(user.firstname) \(user.lastname)").font(.subheadline).foregroundStyle(.gray)
            }
        }
    }
}
