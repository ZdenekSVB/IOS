//
//  Toolbar.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//

import SwiftUI

struct Toolbar: ToolbarContent {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var currentUserViewModel = CurrentUserViewModel()

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: authViewModel.logout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            }
        }

        ToolbarItem(placement: .principal) {
            Text(currentUserViewModel.username)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
}
