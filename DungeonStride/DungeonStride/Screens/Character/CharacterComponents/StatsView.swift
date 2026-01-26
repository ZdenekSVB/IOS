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
            StatRow(name: "physicalDamage", title: "Síla", value: user.stats.physicalDamage, cost: cost, icon: "flame.fill", color: .red, userCoins: user.coins, action: onUpgrade)
            StatRow(name: "defense", title: "Obrana", value: user.stats.defense, cost: cost, icon: "shield.fill", color: .blue, userCoins: user.coins, action: onUpgrade)
            StatRow(name: "magicDamage", title: "Magie", value: user.stats.magicDamage, cost: cost, icon: "sparkles", color: .purple, userCoins: user.coins, action: onUpgrade)
            StatRow(name: "maxHP", title: "Vitalita", value: user.stats.maxHP, cost: cost, icon: "heart.fill", color: .green, userCoins: user.coins, action: onUpgrade)
            
            Section {
                HStack { Text("Zdraví (HP)"); Spacer(); Text("\(user.stats.hp) / \(user.stats.maxHP)").bold() }
            }
        }
    }
}
