//
//  HomeView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 2
    @State private var homeReloadID = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case 0: DungeonMapView()
                        case 1: ActivityView()
                        case 2:
                            HomeContentView()
                                .id(homeReloadID)
                        case 3: CharacterView()
                        case 4: ProfileView()
                        default:
                            HomeContentView()
                                .id(homeReloadID)
                        }
                    }
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 2 {
                    homeReloadID = UUID()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

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
            }
            .padding()
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        guard let uid = authViewModel.currentUserUID else { return }
        lastActivity = await userService.fetchLastActivity(userId: uid)
    }
}
