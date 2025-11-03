//
//  QuestRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct QuestRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quest: Quest
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                
                // Progress Bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(themeManager.backgroundColor)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(width: CGFloat(quest.progress) / CGFloat(quest.total) * 100, height: 4)
                        .cornerRadius(2)
                }
                .frame(width: 100)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("\(quest.progress)/\(quest.total)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryTextColor)
                
                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else if quest.progress >= quest.total {
                    Button("Claim") {
                        onComplete()
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.accentColor)
                    .cornerRadius(6)
                } else {
                    Text("\(quest.total - quest.progress) left")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
        }
        .padding(12)
        .background(themeManager.backgroundColor)
        .cornerRadius(8)
    }
}

struct QuestRow_Previews: PreviewProvider {
    static var previews: some View {
        QuestRow(
            quest: Quest(
                id: 1,
                title: "Daily Steps",
                description: "Walk 10,000 steps",
                progress: 7,
                total: 10,
                isCompleted: false
            ),
            onComplete: {}
        )
        .environmentObject(ThemeManager())
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color("Paleta5"))
    }
}
