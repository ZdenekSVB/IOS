//
//  HomeContentView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct HomeContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Progress Card
                UserProgressCard()
                
                // Last Run Card
                LastRunCard()
                
                // Quests Card
                QuestsCard()
            }
            .padding()
        }
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
            .environmentObject(AuthViewModel())
    }
}
