//
//  HomeComponents.swift
//  DungeonStride
//

import SwiftUI

// MARK: - User Progress Card
struct UserProgressCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Avatar
                if let avatar = userService.currentUser?.selectedAvatar {
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(themeManager.accentColor)
                }
                
                VStack(alignment: .leading) {
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    // Zobrazujeme Username
                    Text(userService.currentUser?.username ?? "Adventurer")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Spacer()
                
                // Level Badge
                VStack {
                    Text("Lvl")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("\(userService.currentUser?.level ?? 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            // XP Progress
            if let user = userService.currentUser {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next Level")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                        Text("\(user.totalXP) / \(user.level * 100) XP")
                            .font(.caption)
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(themeManager.cardBackgroundColor.opacity(0.5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(themeManager.accentColor)
                                .frame(width: min(geometry.size.width * CGFloat(user.levelProgress), geometry.size.width), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
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
    @EnvironmentObject var userService: UserService
    
    // Přijímáme data zvenčí
    let lastActivity: RunActivity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Last Activity")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                if let activity = lastActivity {
                    Text(activity.timeAgo)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            if let activity = lastActivity {
                ZStack {
                    Rectangle()
                        .fill(themeManager.secondaryTextColor.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(8)
                    
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.accentColor)
                    
                    Text(activity.type.capitalized)
                        .font(.caption)
                        .foregroundColor(themeManager.primaryTextColor)
                        .padding(8)
                        .background(themeManager.backgroundColor.opacity(0.8))
                        .cornerRadius(6)
                        .offset(y: 30)
                }
                
                let units = userService.currentUser?.settings.units ?? .metric
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatItem(
                        icon: "figure.walk",
                        title: "Distance",
                        value: units.formatDistance(Int(activity.distanceKm * 1000))
                    )
                    StatItem(
                        icon: "flame.fill",
                        title: "Calories",
                        value: "\(activity.calories)"
                    )
                    StatItem(
                        icon: "timer",
                        title: "Duration",
                        value: activity.duration.stringFormat()
                    )
                    StatItem(
                        icon: "speedometer",
                        title: "Pace",
                        value: formatPace(activity.pace, unit: units)
                    )
                }
            } else {
                // Empty State
                VStack(spacing: 10) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("No activities yet")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("Go to Activity tab to start your first run!")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func formatPace(_ paceMinKm: Double, unit: DistanceUnit) -> String {
        if unit == .metric {
            return String(format: "%.2f min/km", paceMinKm)
        } else {
            return String(format: "%.2f min/mi", paceMinKm * 1.60934)
        }
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
