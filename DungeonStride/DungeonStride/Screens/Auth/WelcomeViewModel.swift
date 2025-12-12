//
//  WelcomeViewModel.swift
//  DungeonStride
//

import Foundation
import FirebaseFirestore

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var uploadMessage: String?
    
    func uploadQuestTemplates() async {
        let db = Firestore.firestore()
        isUploading = true
        uploadMessage = "Uploading quests..."
        
        do {
            let snapshot = try await db.collection("quests").getDocuments()
            for doc in snapshot.documents {
                try await db.collection("quests").document(doc.documentID).delete()
            }
            
            // Předpokládá existenci QuestData.availableQuests
            let quests = QuestData.availableQuests
            
            for quest in quests {
                try await db.collection("quests").document(quest.id).setData(quest.toFirestore())
            }
            
            uploadMessage = "✅ Uploaded \(quests.count) quests successfully!"
        } catch {
            uploadMessage = "❌ Error: \(error.localizedDescription)"
        }
        
        isUploading = false
    }
}
