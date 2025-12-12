//
//  UserProgressCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
//


//
//  HomeComponents.swift
//  DungeonStride
//

import SwiftUI

// MARK: - User Progress Card
struct UserProgressCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text(authViewModel.currentUserEmail ?? "User")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Spacer()
                
                VStack {
                    Text("Lvl")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("5")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to next level")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Spacer()
                    Text("1,250 / 2,000 XP")
                        .font(.caption)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(themeManager.cardBackgroundColor)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(width: 125, height: 8)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Last Run Card
struct LastRunCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Last Run")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                Text("2 hours ago")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            ZStack {
                Rectangle()
                    .fill(themeManager.secondaryTextColor.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
                
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundColor(themeManager.accentColor)
                
                Text("Forest Path")
                    .font(.caption)
                    .foregroundColor(themeManager.primaryTextColor)
                    .padding(8)
                    .background(themeManager.backgroundColor.opacity(0.8))
                    .cornerRadius(6)
                    .offset(y: 30)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatItem(icon: "figure.walk", title: "Distance", value: "5.2 km")
                StatItem(icon: "bolt.fill", title: "Energy", value: "85%")
                StatItem(icon: "star.fill", title: "XP", value: "250")
                StatItem(icon: "heart.fill", title: "Stamina", value: "72%")
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Quests Card
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
                Text("No quests available today")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(questService.dailyQuests) { quest in
                        QuestRow(quest: quest, onComplete: {
                            Task { await completeQuest(quest.id) }
                        })
                    }
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .onAppear { loadQuests() }
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

// MARK: - Quest Row
struct QuestRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quest: Quest
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.iconName)
                .font(.title3)
                .foregroundColor(quest.isCompleted ? .green : themeManager.accentColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(quest.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.primaryTextColor)
                    Spacer()
                    if quest.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
                
                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                
                ProgressView(value: quest.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: quest.isCompleted ? .green : themeManager.accentColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                
                HStack {
                    Text("\(quest.progress)/\(quest.totalRequired)")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Spacer()
                    Text("+\(quest.xpReward) XP")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
            
            if !quest.isCompleted {
                Button(action: onComplete) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(themeManager.accentColor)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Stat Components
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(themeManager.secondaryTextColor)
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(themeManager.primaryTextColor)
            }
            Spacer()
        }
        .padding(8)
        .background(themeManager.backgroundColor)
        .cornerRadius(8)
    }
}
