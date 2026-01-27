//
//  StatsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct StatsView: View {
    let user: User
    let onUpgrade: (String, Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header s body
            HStack {
                Text("Available Points:") // Lokalizace
                    .font(.headline)
                    .foregroundColor(Color(UIColor.label))
                Spacer()
                Text("\(user.statPoints)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(user.statPoints > 0 ? .green : .gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            List {
                let cost = 1 // Cena je vždy 1 bod
                
                StatRow(name: "physicalDamage", title: "Strength", value: user.stats.physicalDamage, cost: cost, icon: "flame.fill", color: .red, currency: user.statPoints, action: onUpgrade)
                
                StatRow(name: "defense", title: "Defense", value: user.stats.defense, cost: cost, icon: "shield.fill", color: .blue, currency: user.statPoints, action: onUpgrade)
                
                StatRow(name: "magicDamage", title: "Magic", value: user.stats.magicDamage, cost: cost, icon: "sparkles", color: .purple, currency: user.statPoints, action: onUpgrade)
                
                StatRow(name: "maxHP", title: "Vitality", value: user.stats.maxHP, cost: cost, icon: "heart.fill", color: .green, currency: user.statPoints, action: onUpgrade)
                
                Section {
                    HStack {
                        Text("Health (HP)") // Lokalizace
                        Spacer()
                        Text("\(user.stats.hp) / \(user.stats.maxHP)").bold()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
