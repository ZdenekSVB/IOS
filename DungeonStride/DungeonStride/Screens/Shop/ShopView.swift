//
//  ShopView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct ShopView: View {
    var body: some View {
        ZStack {
            Color("Paleta3").ignoresSafeArea()
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
