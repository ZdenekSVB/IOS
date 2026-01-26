//
//  QuestsCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct QuestsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var questService: QuestService
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Quests", comment: "Section title")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                if questService.isLoading {
                    ProgressView().scaleEffect(0.8)
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
                Text("No quests available today", comment: "Empty quests state")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(questService.dailyQuests) { quest in
                        QuestRow(quest: quest)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .onChange(of: userService.currentUser?.uid) { _, _ in
            loadQuests()
        }
    }
    
    private func loadQuests() {
        guard let userId = userService.currentUser?.uid else { return }
        Task {
            try? await questService.loadDailyQuests(for: userId)
        }
    }
}
