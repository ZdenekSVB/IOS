//
//  ProfileViewModel.swift
//  DungeonStride
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    private var userService: UserService
    private var authViewModel: AuthViewModel
    
    @Published var showSettings = false
    
    init(userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
    }
    
    func logout() {
        authViewModel.logout()
    }
}
