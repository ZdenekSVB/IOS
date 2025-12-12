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
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case 0: DungeonMapView()
                        case 1: ActivityView()
                        case 2: HomeContentView()
                        case 3: ShopView()
                        case 4: ProfileView()
                        default: HomeContentView()
                        }
                    }
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                UserProgressCard()
                LastRunCard()
                QuestsCard()
            }
            .padding()
        }
    }
}
