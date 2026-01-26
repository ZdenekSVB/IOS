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
        List {
            let cost = 100
            // Názvy statů jako LocalizedStringKey
            StatRow(name: "physicalDamage", title: "Strength", value: user.stats.physicalDamage, cost: cost, icon: "flame.fill", color: .red, userCoins: user.coins, action: onUpgrade)
            StatRow(name: "defense", title: "Defense", value: user.stats.defense, cost: cost, icon: "shield.fill", color: .blue, userCoins: user.coins, action: onUpgrade)
            StatRow(name: "magicDamage", title: "Magic", value: user.stats.magicDamage, cost: cost, icon: "sparkles", color: .purple, userCoins: user.coins, action: onUpgrade)
            StatRow(name: "maxHP", title: "Vitality", value: user.stats.maxHP, cost: cost, icon: "heart.fill", color: .green, userCoins: user.coins, action: onUpgrade)
            
            Section {
                HStack {
                    Text("Health (HP)") // Lokalizace
                    Spacer()
                    Text("\(user.stats.hp) / \(user.stats.maxHP)").bold()
                }
            }
        }
    }
}
