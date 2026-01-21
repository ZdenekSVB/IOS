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
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var saveSuccess: Bool = false
    
    private let userService: UserService
    private let currentUser: User
    
    init(user: User, userService: UserService) {
        self.currentUser = user
        self.userService = userService
        self.username = user.username
        self.selectedAvatar = user.selectedAvatar
    }
    
    func saveChanges() {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Uživatelské jméno nesmí být prázdné."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                var newUser = User(
                    id: currentUser.id,
                    email: currentUser.email,
                    username: username,
                    createdAt: currentUser.createdAt,
                    updatedAt: Date(),
                    lastActiveAt: currentUser.lastActiveAt
                )
                
                newUser.selectedAvatar = selectedAvatar
                
                // Kopírování existujících dat
                newUser.activityStats = currentUser.activityStats
                newUser.dailyActivity = currentUser.dailyActivity
                newUser.settings = currentUser.settings
                newUser.coins = currentUser.coins
                newUser.totalXP = currentUser.totalXP
                newUser.totalQuestsCompleted = currentUser.totalQuestsCompleted
                newUser.equippedIds = currentUser.equippedIds
                
                // ZPĚT: Zachování dat z obchodu
                newUser.shopData = currentUser.shopData
                
                try await userService.updateUser(newUser)
                
                self.saveSuccess = true
            } catch {
                self.errorMessage = "Chyba při ukládání: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
