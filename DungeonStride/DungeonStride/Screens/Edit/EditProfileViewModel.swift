//
//  EditProfileViewModel.swift
//  DungeonStride
//

import SwiftUI
import FirebaseFirestore

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var selectedAvatar: String = "avatar1"
    
    // --- NOVÉ: Proměnná pro zobrazení emailu ---
    @Published var email: String = ""
    
    // Hesla
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var saveSuccess: Bool = false
    
    private let userService: UserService
    private let authViewModel: AuthViewModel
    private let currentUser: User
    
    init(user: User, userService: UserService, authViewModel: AuthViewModel) {
        self.currentUser = user
        self.userService = userService
        self.authViewModel = authViewModel
        
        self.username = user.username
        self.selectedAvatar = user.selectedAvatar
        // Zde načteme email přímo z uživatele
        self.email = user.email
    }
    
    func saveChanges() {
        // Validace
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Uživatelské jméno nesmí být prázdné."
            return
        }
        
        let isChangingPassword = !newPassword.isEmpty || !oldPassword.isEmpty
        
        if isChangingPassword {
            if oldPassword.isEmpty {
                errorMessage = "Pro změnu hesla musíte zadat své stávající heslo."
                return
            }
            if newPassword.count < 6 {
                errorMessage = "Nové heslo musí mít alespoň 6 znaků."
                return
            }
            if newPassword != confirmNewPassword {
                errorMessage = "Nová hesla se neshodují."
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isChangingPassword {
                    try await authViewModel.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
                }
                
                var newUser = User(
                    id: currentUser.id,
                    email: currentUser.email, // Email se nemění, bere se z původního
                    username: username,
                    createdAt: currentUser.createdAt,
                    updatedAt: Date(),
                    lastActiveAt: currentUser.lastActiveAt
                )
                
                newUser.selectedAvatar = selectedAvatar
                
                // Kopírování ostatních dat
                newUser.activityStats = currentUser.activityStats
                newUser.dailyActivity = currentUser.dailyActivity
                newUser.settings = currentUser.settings
                newUser.coins = currentUser.coins
                newUser.totalXP = currentUser.totalXP
                newUser.totalQuestsCompleted = currentUser.totalQuestsCompleted
                newUser.equippedIds = currentUser.equippedIds
                newUser.shopData = currentUser.shopData
                
                try await userService.updateUser(newUser)
                
                self.saveSuccess = true
            } catch {
                self.errorMessage = "Chyba: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
