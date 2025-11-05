//
//  QuestRow.swift
//  DungeonStride
//

import SwiftUI

struct QuestRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quest: Quest
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Quest Icon
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
                
                // Progress Bar
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
            
            // Complete Button
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

struct QuestRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            QuestRow(
                quest: Quest(
                    id: "1",
                    title: "Daily Steps",
                    description: "Walk 10,000 steps",
                    iconName: "figure.walk",
                    xpReward: 100,
                    requirement: .steps(10000),
                    progress: 7500
                ),
                onComplete: {}
            )
            
            QuestRow(
                quest: Quest(
                    id: "2",
                    title: "Completed Quest",
                    description: "This quest is done",
                    iconName: "flame",
                    xpReward: 150,
                    requirement: .calories(500),
                    progress: 500
                ),
                onComplete: {}
            )
        }
        .environmentObject(ThemeManager())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
