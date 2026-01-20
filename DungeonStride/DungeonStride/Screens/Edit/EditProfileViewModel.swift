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
                // OPRAVA: Vytvoříme novou instanci User s novým jménem a avatarem.
                // Protože 'username' je 'let', musíme vytvořit úplně nový objekt.
                
                var newUser = User(
                    id: currentUser.id,
                    email: currentUser.email,
                    username: username, // ZDE vkládáme nové jméno
                    createdAt: currentUser.createdAt,
                    updatedAt: Date(), // Aktualizujeme čas
                    lastActiveAt: currentUser.lastActiveAt
                )
                
                // Nyní zkopírujeme ostatní data, která User(...) init nenastavil
                // (protože váš init v User.swift nastavuje jen základní věci a zbytek nechává na defaultu)
                
                newUser.selectedAvatar = selectedAvatar // ZDE vkládáme nový avatar
                
                // Kopírování ostatních dat (aby se neztratil postup)
                newUser.stats = currentUser.stats
                newUser.activityStats = currentUser.activityStats
                newUser.dailyActivity = currentUser.dailyActivity
                newUser.settings = currentUser.settings
                newUser.coins = currentUser.coins
                newUser.gems = currentUser.gems
                newUser.premiumMember = currentUser.premiumMember
                newUser.totalXP = currentUser.totalXP
                newUser.myAchievements = currentUser.myAchievements
                newUser.currentQuests = currentUser.currentQuests
                newUser.completedQuests = currentUser.completedQuests
                newUser.equippedIds = currentUser.equippedIds
                newUser.shopData = currentUser.shopData
                
                // Uložíme do databáze
                try await userService.updateUser(newUser)
                
                self.saveSuccess = true
            } catch {
                self.errorMessage = "Chyba při ukládání: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
