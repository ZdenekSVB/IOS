//
//  QuestsCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


import SwiftUI

struct QuestsCard: View {
    @State private var quests: [Quest] = [
        Quest(id: 1, title: "Daily Steps", description: "Walk 10,000 steps", progress: 7, total: 10, isCompleted: false),
        Quest(id: 2, title: "Forest Explorer", description: "Complete 3 forest runs", progress: 2, total: 3, isCompleted: false),
        Quest(id: 3, title: "Energy Master", description: "Keep energy above 80% for a day", progress: 1, total: 1, isCompleted: true)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Quests")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(quests.filter { $0.isCompleted }.count)/\(quests.count)")
                    .font(.caption)
                    .foregroundColor(Color("Paleta4"))
            }
            
            VStack(spacing: 12) {
                ForEach(quests) { quest in
                    QuestRow(quest: quest, onComplete: {
                        completeQuest(quest.id)
                    })
                }
            }
        }
        .padding()
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
    
    private func completeQuest(_ questId: Int) {
        if let index = quests.firstIndex(where: { $0.id == questId }) {
            quests[index].isCompleted = true
            // Simulace znovu vygenerování questu po 10 vteřinách
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if let index = quests.firstIndex(where: { $0.id == questId }) {
                    quests[index].isCompleted = false
                    quests[index].progress = 0
                }
            }
        }
    }
}

struct QuestsCard_Previews: PreviewProvider {
    static var previews: some View {
        QuestsCard()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
