//
//  ProfileViewModel.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
//


//
//  ProfileViewModel.swift
//  DungeonStride
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    private let userService: UserService
    private let authViewModel: AuthViewModel
    
    @Published var selectedAvatar: String = "avatar1"
    @Published var showAvatarPicker = false
    @Published var showSettings = false
    
    let predefinedAvatars = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6"]
    
    init(userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
        
        if let avatar = userService.currentUser?.selectedAvatar {
            self.selectedAvatar = avatar
        }
    }
    
    func updateAvatar(to newAvatar: String) {
        guard let uid = authViewModel.currentUserUID else { return }
        
        Task {
            do {
                try await userService.updateSelectedAvatar(uid: uid, avatarName: newAvatar)
                selectedAvatar = newAvatar
                showAvatarPicker = false
            } catch {
                print("Failed to update avatar: \(error.localizedDescription)")
            }
        }
    }
    
    func logout() {
        authViewModel.logout()
    }
}