//
//  HomeContentView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI
import MapKit

struct HomeContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var lastActivity: RunActivity?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                UserProgressCard()
                LastRunCard(lastActivity: lastActivity)
                QuestsCard()
                
                // Přidáme trochu místa dole, aby obsah nebyl schovaný za vyčuhujícím TabBarem
                Spacer().frame(height: 50)
            }
            .padding()
        }
        .task {
            if let uid = authViewModel.currentUserUID {
                lastActivity = await userService.fetchLastActivity(userId: uid)
            }
        }
        .onChange(of: authViewModel.currentUserUID) { _, newUid in
            if let uid = newUid {
                Task {
                    lastActivity = await userService.fetchLastActivity(userId: uid)
                }
            }
        }
    }
}
