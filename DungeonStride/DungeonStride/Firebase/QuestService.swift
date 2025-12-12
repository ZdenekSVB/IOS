//
//  QuestService.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore
import Combine

class QuestService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var dailyQuests: [Quest] = []
    @Published var isLoading = false
    
    // MARK: - Logic
    
    func generateDailyQuests() -> [Quest] {
        let shuffledQuests = QuestData.availableQuests.shuffled()
        return Array(shuffledQuests.prefix(3)).map { quest in
            Quest(
                id: quest.id,
                title: quest.title,
                description: quest.description,
                iconName: quest.iconName,
                xpReward: quest.xpReward,
                requirement: quest.requirement,
                progress: 0,
                startedAt: Date()
            )
        }
    }
    
    func loadDailyQuests(for userId: String) async throws {
        await MainActor.run { isLoading = true }
        
        let today = Calendar.current.startOfDay(for: Date())
        let questsCollection = db.collection("users").document(userId).collection("dailyQuests")
        let todayQuestsQuery = questsCollection.whereField("startedAt", isGreaterThan: Timestamp(date: today))
        
        let snapshot = try await todayQuestsQuery.getDocuments()
        
        if snapshot.documents.isEmpty {
            let newQuests = generateDailyQuests()
            
            for quest in newQuests {
                try await questsCollection.document(quest.id).setData(quest.toFirestore())
            }
            
            await MainActor.run {
                dailyQuests = newQuests
            }
        } else {
            let quests = snapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
            await MainActor.run {
                dailyQuests = quests
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    func updateQuestProgress(userId: String, questId: String, progress: Int) async throws {
        let questRef = db.collection("users").document(userId).collection("dailyQuests").document(questId)
        
        let quest = dailyQuests.first { $0.id == questId }
        let isCompleted = progress >= (quest?.totalRequired ?? 0)
        
        var updateData: [String: Any] = [
            "progress": progress,
            "isCompleted": isCompleted,
            "updatedAt": Timestamp(date: Date())
        ]
        
        if isCompleted {
            updateData["completedAt"] = Timestamp(date: Date())
        }
        
        try await questRef.updateData(updateData)
        
        if let index = dailyQuests.firstIndex(where: { $0.id == questId }) {
            await MainActor.run {
                dailyQuests[index].updateProgress(progress)
            }
        }
    }
    
    func completeQuest(userId: String, questId: String) async throws {
        if let quest = dailyQuests.first(where: { $0.id == questId }) {
            try await updateQuestProgress(userId: userId, questId: questId, progress: quest.totalRequired)
        }
    }
    
    func fetchAllQuests() async throws -> [Quest] {
        let snapshot = try await db.collection("quests").getDocuments()
        return snapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
    }
    
    func generateDailyQuestsFromFirestore() async throws -> [Quest] {
        let allQuests = try await fetchAllQuests()
        let selected = Array(allQuests.shuffled().prefix(3))
        return selected.map { Quest(
            id: $0.id,
            title: $0.title,
            description: $0.description,
            iconName: $0.iconName,
            xpReward: $0.xpReward,
            requirement: $0.requirement,
            progress: 0
        )}
    }
}
