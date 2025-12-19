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
    
    // MARK: - Daily Loading Logic
    
    /// Zkontroluje, zda má uživatel úkoly pro dnešek.
    /// Pokud ne (nebo je nový den), stáhne šablony z Firestore 'quests' a vybere 3 náhodné.
    func loadDailyQuests(for userId: String) async throws {
        await MainActor.run { isLoading = true }
        
        let today = Calendar.current.startOfDay(for: Date())
        let userQuestsRef = db.collection("users").document(userId).collection("dailyQuests")
        
        // 1. Podíváme se do uživatelovy sub-kolekce, jestli už má úkoly vygenerované pro dnešek
        let todayQuestsQuery = userQuestsRef.whereField("startedAt", isGreaterThan: Timestamp(date: today))
        let snapshot = try await todayQuestsQuery.getDocuments()
        
        if snapshot.documents.isEmpty {
            // Nemá úkoly pro dnešek -> Stáhnout šablony z hlavní DB a vygenerovat
            print("📅 No quests for today in user profile. Fetching templates from Firestore...")
            await fetchTemplatesAndAssign(to: userQuestsRef)
        } else {
            // Má úkoly -> Načíst je
            print("✅ Found existing quests for today.")
            let quests = snapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
            await MainActor.run {
                self.dailyQuests = quests
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    /// Vynutí smazání starých a vygenerování nových questů (voláno z AuthViewModel při změně dne)
    func regenerateDailyQuests(for userId: String) async throws {
        await MainActor.run { isLoading = true }
        
        let userQuestsRef = db.collection("users").document(userId).collection("dailyQuests")
        
        print("🔄 Regenerating quests due to daily reset...")
        
        // 1. Smazat staré úkoly z uživatelovy kolekce
        let allDocs = try await userQuestsRef.getDocuments()
        for doc in allDocs.documents {
            try await userQuestsRef.document(doc.documentID).delete()
        }
        
        // 2. Vygenerovat nové stažením z Firestore
        await fetchTemplatesAndAssign(to: userQuestsRef)
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - Firestore Template Logic
    
    private func fetchTemplatesAndAssign(to collection: CollectionReference) async {
        do {
            // 1. Stáhnout VŠECHNY šablony z hlavní kolekce "quests" ve Firestore
            // ZDE SE BEROU DATA Z FIRESTORE, NIC SE NEVYTVÁŘÍ LOKÁLNĚ
            let templatesSnapshot = try await db.collection("quests").getDocuments()
            let templates = templatesSnapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
            
            // Pojistka, pokud je databáze prázdná
            guard !templates.isEmpty else {
                print("⚠️ ERROR: Collection 'quests' in Firestore is empty!")
                await MainActor.run { self.dailyQuests = [] }
                return
            }
            
            // 2. Vybrat 3 náhodné
            let shuffled = templates.shuffled()
            let selected = Array(shuffled.prefix(3))
            
            // 3. Vytvořit instance pro uživatele (reset progressu, nastavit dnešní datum)
            let newQuests = selected.map { template in
                Quest(
                    id: template.id, // ID zůstává stejné jako v šabloně (nebo můžeš generovat UUID)
                    title: template.title,
                    description: template.description,
                    iconName: template.iconName,
                    xpReward: template.xpReward,
                    requirement: template.requirement,
                    progress: 0,
                    startedAt: Date()
                )
            }
            
            // 4. Uložit do uživatelovy sub-kolekce
            for quest in newQuests {
                try await collection.document(quest.id).setData(quest.toFirestore())
            }
            
            // 5. Aktualizovat UI
            await MainActor.run {
                self.dailyQuests = newQuests
            }
            
        } catch {
            print("❌ Error fetching templates from Firestore: \(error)")
        }
    }
    
    // MARK: - Activity Synchronization
    
    /// Tato funkce se zavolá po aktivitě. Vezme hodnoty z User.dailyActivity (které jsou z DB)
    /// a porovná je s požadavky questů.
    func updateQuestsFromDailyStats(user: User) async {
        guard let userId = user.id else { return }
        print("📊 Syncing quests with Daily Activity: Steps: \(user.dailyActivity.dailySteps)")
        
        for quest in dailyQuests {
            if quest.isCompleted { continue }
            
            var newProgress = quest.progress
            
            // Mapování dailyActivity na požadavky questu
            switch quest.requirement {
            case .steps(_):
                newProgress = user.dailyActivity.dailySteps
            case .distance(_):
                newProgress = user.dailyActivity.dailyDistance // v metrech
            case .calories(_):
                newProgress = user.dailyActivity.dailyCaloriesBurned
            case .runs(_):
                // Pro runs používáme totalRuns z activityStats,
                // protože dailyRuns v modelu User chybí (pokud jsi ho tam nepřidal).
                // Alternativně: pokud se tato funkce volá po doběhnutí, přičti +1 k progressu questu.
                // Zde předpokládám logiku "cumulative total":
                newProgress = user.activityStats.totalRuns
            case .dailyLogin(_):
                break // Řeší se při loginu
            }
            
            // Pokud se progress zvýšil, aktualizujeme ve Firestore
            if newProgress > quest.progress {
                try? await updateQuestProgress(userId: userId, questId: quest.id, progress: newProgress)
            }
        }
    }
    
    func updateQuestProgress(userId: String, questId: String, progress: Int) async throws {
        let questRef = db.collection("users").document(userId).collection("dailyQuests").document(questId)
        
        guard let quest = dailyQuests.first(where: { $0.id == questId }) else { return }
        
        let isCompleted = progress >= quest.totalRequired
        
        var updateData: [String: Any] = [
            "progress": progress,
            "isCompleted": isCompleted,
            "updatedAt": Timestamp(date: Date())
        ]
        
        if isCompleted && quest.completedAt == nil {
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
}
