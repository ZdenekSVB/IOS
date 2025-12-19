    //
    //  WelcomeViewModel.swift
    //  DungeonStride
    //

    import Foundation
    import FirebaseFirestore

    @MainActor
    class WelcomeViewModel: ObservableObject {
        @Published var isProcessing = false
        @Published var statusMessage: String?
        
        /// Načte šablony přímo z Firestore (kolekce 'quests') a vygeneruje z nich
        /// nové denní úkoly pro zadaného uživatele.
        func generateQuestsFromFirestore(for userId: String) async {
            let db = Firestore.firestore()
            isProcessing = true
            statusMessage = "Fetching quests from Firestore..."
            
            do {
                // 1. Stáhnout šablony z kolekce "quests" (přímo z Firestore)
                let templatesSnapshot = try await db.collection("quests").getDocuments()
                let templates = templatesSnapshot.documents.compactMap { Quest.fromFirestore($0.data()) }
                
                guard !templates.isEmpty else {
                    statusMessage = "⚠️ No quest templates found in Firestore."
                    isProcessing = false
                    return
                }
                
                // 2. Vybrat 3 náhodné
                let shuffled = templates.shuffled()
                let selected = Array(shuffled.prefix(3))
                
                // 3. Vytvořit nové instance pro uživatele (s dnešním datem a nulovým progresem)
                let newQuests = selected.map { template in
                    Quest(
                        id: template.id, // ID šablony
                        title: template.title,
                        description: template.description,
                        iconName: template.iconName,
                        xpReward: template.xpReward,
                        requirement: template.requirement,
                        progress: 0,
                        startedAt: Date()
                    )
                }
                
                // 4. Smazat staré denní úkoly uživatele
                let userQuestsRef = db.collection("users").document(userId).collection("dailyQuests")
                let oldDocs = try await userQuestsRef.getDocuments()
                for doc in oldDocs.documents {
                    try await userQuestsRef.document(doc.documentID).delete()
                }
                
                // 5. Uložit nové úkoly uživateli
                for quest in newQuests {
                    try await userQuestsRef.document(quest.id).setData(quest.toFirestore())
                }
                
                statusMessage = "✅ Successfully generated \(newQuests.count) quests from Firestore!"
                
            } catch {
                statusMessage = "❌ Error: \(error.localizedDescription)"
            }
            
            isProcessing = false
        }
    }
