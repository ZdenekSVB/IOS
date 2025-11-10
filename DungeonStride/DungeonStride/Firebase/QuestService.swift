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
    
    // Pre-definované questy
    private let availableQuests: [Quest] = [
        Quest(
            id: "daily_steps_10000",
            title: "Step Master",
            description: "Walk 10,000 steps today",
            iconName: "figure.walk",
            xpReward: 100,
            requirement: .steps(10000)
        ),
        Quest(
            id: "daily_distance_5k",
            title: "Distance Runner",
            description: "Run 5 km today",
            iconName: "road.lanes",
            xpReward: 150,
            requirement: .distance(5000)
        ),
        Quest(
            id: "daily_calories_500",
            title: "Calorie Burner",
            description: "Burn 500 calories",
            iconName: "flame",
            xpReward: 120,
            requirement: .calories(500)
        ),
        Quest(
            id: "daily_runs_2",
            title: "Running Enthusiast",
            description: "Complete 2 runs",
            iconName: "repeat",
            xpReward: 200,
            requirement: .runs(2)
        ),
        Quest(
            id: "daily_login_3",
            title: "Dedicated Strider",
            description: "Login for 3 consecutive days",
            iconName: "calendar",
            xpReward: 80,
            requirement: .dailyLogin(3)
        )
    ]
    
    func generateDailyQuests() -> [Quest] {
        // Vybrat 3 náhodné questy z dostupných
        let shuffledQuests = availableQuests.shuffled()
        return Array(shuffledQuests.prefix(3)).map { quest in
            // Vytvořit novou instanci s aktuálním datem
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
        
        // Zkontrolovat, jestli máme questy pro dnešek
        let today = Calendar.current.startOfDay(for: Date())
        let questsCollection = db.collection("users").document(userId).collection("dailyQuests")
        let todayQuestsQuery = questsCollection.whereField("startedAt", isGreaterThan: Timestamp(date: today))
        
        let snapshot = try await todayQuestsQuery.getDocuments()
        
        if snapshot.documents.isEmpty {
            // Generovat nové denní questy
            let newQuests = generateDailyQuests()
            
            // Uložit do Firestore - použijeme questsCollection místo query
            for quest in newQuests {
                try await questsCollection.document(quest.id).setData(quest.toFirestore())
            }
            
            await MainActor.run {
                dailyQuests = newQuests
            }
        } else {
            // Načíst existující questy
            let quests = snapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
            await MainActor.run {
                dailyQuests = quests
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    func updateQuestProgress(userId: String, questId: String, progress: Int) async throws {
        let questRef = db.collection("users").document(userId).collection("dailyQuests").document(questId)
        
        // Najít quest pro získání totalRequired
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
        
        // Aktualizovat lokální data
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
