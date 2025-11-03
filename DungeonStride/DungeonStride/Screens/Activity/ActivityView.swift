//
//  ActivityView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct ActivityView: View {
    var body: some View {
        ZStack {
            Color("Paleta3").ignoresSafeArea()
            VStack {
                Text("Activity")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Coming soon...")
                    .foregroundColor(Color("Paleta4"))
            }
        }
    }
}
