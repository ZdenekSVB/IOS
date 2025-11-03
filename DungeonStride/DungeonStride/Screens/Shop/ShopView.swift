//
//  ShopView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var themeManager: ThemeManager // ← PŘIDÁNO
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamické pozadí podle tématu
                themeManager.backgroundColor
                    .ignoresSafeArea()
                VStack {
                    Text("Shop")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Coming soon...")
                        .foregroundColor(Color("Paleta4"))
                }
            }
        }
    }
}
