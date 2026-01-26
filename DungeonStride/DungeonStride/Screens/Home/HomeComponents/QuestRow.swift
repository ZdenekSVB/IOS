//
//  QuestRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI
import MapKit

struct QuestRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quest: Quest
    
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
                    
                    // Zobrazení odměn (XP + Coins)
                    HStack(spacing: 8) {
                            Text("+\(quest.xpReward) XP")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        
                            HStack(spacing: 2) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text("\(quest.coinsReward)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                        }
                    
                }
            }
        }
        .padding(.vertical, 4)
    }
}
