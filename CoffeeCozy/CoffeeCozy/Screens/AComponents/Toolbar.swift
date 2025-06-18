//
//  UserToolbar.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//
import SwiftUI

struct UserToolbar: ToolbarContent {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var currentUserViewModel = CurrentUserViewModel()

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Text(currentUserViewModel.username)
                    .font(.headline)
                    .foregroundColor(.black)

                Button(action: authViewModel.logout) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Odhlásit")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
//
//  AdminToolbar.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//


import SwiftUI

struct AdminToolbar: ToolbarContent {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var currentUserViewModel = CurrentUserViewModel()

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Text(currentUserViewModel.username)
                    .font(.headline)
                    .foregroundColor(.black)

                Button(action: authViewModel.logout) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Odhlásit")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
