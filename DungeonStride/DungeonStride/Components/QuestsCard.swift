//
//  QuestsCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct QuestsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var questService: QuestService
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Quests")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Spacer()
                
                if questService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("\(questService.dailyQuests.filter { $0.isCompleted }.count)/\(questService.dailyQuests.count)")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            if questService.isLoading {
                ProgressView("Loading quests...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if questService.dailyQuests.isEmpty {
                Text("No quests available today")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(questService.dailyQuests) { quest in
                        QuestRow(quest: quest, onComplete: {
                            Task {
                                await completeQuest(quest.id)
                            }
                        })
                        .environmentObject(themeManager)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .onAppear {
            loadQuests()
        }
    }
    
    private func loadQuests() {
        Task {
            if let userId = userService.currentUser?.uid {
                try? await questService.loadDailyQuests(for: userId)
            }
        }
    }
    
    private func completeQuest(_ questId: String) async {
        guard let userId = userService.currentUser?.uid else { return }
        
        do {
            try await questService.completeQuest(userId: userId, questId: questId)
            
            // Přidat odměny uživateli
            if let quest = questService.dailyQuests.first(where: { $0.id == questId }),
               var user = userService.currentUser {
                user.addXP(quest.xpReward)
                user.addCoins(quest.xpReward / 10)
                try await userService.updateUser(user)
            }
        } catch {
            print("Error completing quest: \(error)")
        }
    }
}
