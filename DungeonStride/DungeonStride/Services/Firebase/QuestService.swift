//
//  QuestService.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

class QuestService: ObservableObject {
    private let db = Firestore.firestore()
    
    // ZMĚNA: Přístup k AuthService přes DI
    private var authService: AuthService { DIContainer.shared.resolve() }
    
    @Published var dailyQuests: [Quest] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthListener()
    }
    
    // MARK: - Auto-Sync
    
    private func setupAuthListener() {
        Task { @MainActor in
            authService.$user
                .receive(on: DispatchQueue.main)
                .sink { [weak self] firebaseUser in
                    guard let self = self else { return }
                    if let uid = firebaseUser?.uid {
                        // Uživatel se přihlásil -> načti questy
                        Task {
                            try? await self.loadDailyQuests(for: uid)
                        }
                    } else {
                        // Odhlášení -> vyčisti
                        self.dailyQuests = []
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Daily Loading Logic
    
    func loadDailyQuests(for userId: String) async throws {
        await MainActor.run { isLoading = true }
        
        let today = Calendar.current.startOfDay(for: Date())
        let userQuestsRef = db.collection("users").document(userId).collection("dailyQuests")
        
        let todayQuestsQuery = userQuestsRef.whereField("startedAt", isGreaterThan: Timestamp(date: today))
        let snapshot = try await todayQuestsQuery.getDocuments()
        
        if snapshot.documents.isEmpty {
            print("📅 No quests for today. Fetching templates...")
            await fetchTemplatesAndAssign(to: userQuestsRef)
        } else {
            print("✅ Loaded existing daily quests.")
            let quests = snapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
            await MainActor.run {
                self.dailyQuests = quests
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    func regenerateDailyQuests(for userId: String) async throws {
        await MainActor.run { isLoading = true }
        
        let userQuestsRef = db.collection("users").document(userId).collection("dailyQuests")
        print("🔄 Regenerating quests...")
        
        let allDocs = try await userQuestsRef.getDocuments()
        for doc in allDocs.documents {
            try await userQuestsRef.document(doc.documentID).delete()
        }
        
        await fetchTemplatesAndAssign(to: userQuestsRef)
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - Firestore Template Logic
    
    private func fetchTemplatesAndAssign(to collection: CollectionReference) async {
        do {
            let templatesSnapshot = try await db.collection("quests").getDocuments()
            let templates = templatesSnapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
            
            guard !templates.isEmpty else {
                print("⚠️ Firestore 'quests' collection is empty!")
                await MainActor.run { self.dailyQuests = [] }
                return
            }
            
            let shuffled = templates.shuffled()
            let selected = Array(shuffled.prefix(3))
            
            let newQuests = selected.map { template in
                Quest(
                    id: template.id,
                    title: template.title,
                    description: template.description,
                    iconName: template.iconName,
                    xpReward: template.xpReward,
                    coinsReward: template.coinsReward,
                    requirement: template.requirement,
                    progress: 0,
                    startedAt: Date()
                )
            }
            
            for quest in newQuests {
                try await collection.document(quest.id).setData(quest.toFirestore())
            }
            
            await MainActor.run {
                self.dailyQuests = newQuests
            }
            
        } catch {
            print("❌ Error fetching quest templates: \(error)")
        }
    }
    
    // MARK: - Activity Synchronization
    
    func updateQuestsFromDailyStats(user: User) async {
        guard let userId = user.id else { return }
        print("📊 Updating quest progress from stats...")
        
        for quest in dailyQuests {
            if quest.isCompleted { continue }
            
            var newProgress = quest.progress
            
            switch quest.requirement {
            case .steps(_):
                newProgress = user.dailyActivity.dailySteps
            case .distance(_):
                newProgress = user.dailyActivity.dailyDistance
            case .calories(_):
                newProgress = user.dailyActivity.dailyCaloriesBurned
            case .runs(_):
                newProgress = user.activityStats.totalRuns
            case .dailyLogin(_):
                break
            }
            
            if newProgress > quest.progress {
                try? await updateQuestProgress(userId: userId, questId: quest.id, progress: newProgress)
            }
        }
    }
    
    func updateQuestProgress(userId: String, questId: String, progress: Int) async throws {
        let questRef = db.collection("users").document(userId).collection("dailyQuests").document(questId)
        
        guard let quest = dailyQuests.first(where: { $0.id == questId }) else { return }
        
        let wasCompleted = quest.isCompleted
        let isNowCompleted = progress >= quest.totalRequired
        
        var updateData: [String: Any] = [
            "progress": progress,
            "isCompleted": isNowCompleted,
            "updatedAt": Timestamp(date: Date())
        ]
        
        if isNowCompleted && !wasCompleted {
            updateData["completedAt"] = Timestamp(date: Date())
            try? await incrementUserStats(userId: userId, xpReward: quest.xpReward, coinsReward: quest.coinsReward)
            
            // Haptická odezva
            await MainActor.run {
                HapticManager.shared.success()
            }
        }
        
        try await questRef.updateData(updateData)
        
        if let index = dailyQuests.firstIndex(where: { $0.id == questId }) {
            await MainActor.run {
                dailyQuests[index].updateProgress(progress)
                if isNowCompleted { dailyQuests[index].isCompleted = true }
            }
        }
    }
    
    private func incrementUserStats(userId: String, xpReward: Int, coinsReward: Int) async throws {
        let userRef = db.collection("users").document(userId)
        
        let data: [String: Any] = [
            "totalQuestsCompleted": FieldValue.increment(Int64(1)),
            "totalXP": FieldValue.increment(Int64(xpReward)),
            "coins": FieldValue.increment(Int64(coinsReward))
        ]
        
        try await userRef.updateData(data)
        print("🎉 Quest Rewards: +\(xpReward) XP, +\(coinsReward) Coins")
    }
    
    func completeQuest(userId: String, questId: String) async throws {
        if let quest = dailyQuests.first(where: { $0.id == questId }) {
            try await updateQuestProgress(userId: userId, questId: questId, progress: quest.totalRequired)
        }
    }
}
