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
                    // Inteligentní kontejner pro obsah (oddělený switch)
                    TabContentView(selectedTab: $selectedTab, homeReloadID: $homeReloadID)
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            // OPRAVA: onChange s dvěma parametry (oldValue, newValue) pro iOS 17+
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 2 {
                    homeReloadID = UUID()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Toto můžeš dát do samostatného souboru, např. TabContentView.swift,
// nebo nechat zde, pokud chceš mít vše v jednom.
struct TabContentView: View {
    @Binding var selectedTab: Int
    @Binding var homeReloadID: UUID
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                DungeonMapView()
            case 1:
                ActivityView()
            case 2:
                HomeContentView()
                    .id(homeReloadID)
            case 3:
                ShopView()
            case 4:
                ProfileView()
            case 5:
                // ZDE PŘIDÁVÁME HISTORII
                HistoryView()
            default:
                HomeContentView()
                    .id(homeReloadID)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
