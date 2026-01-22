//
//  HomeView.swift
//  DungeonStride
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var questService: QuestService
    
    // Defaultně vybraná záložka 0 (Home)
    @State private var selectedTab = 0
    @State private var homeReloadID = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Obsah záložek
                    TabContentView(selectedTab: $selectedTab, homeReloadID: $homeReloadID)
                    
                    // Vlastní spodní lišta
                    // zIndex(1) zajistí, že vyčuhující tlačítko "Run" bude vizuálně NAD obsahem stránky
                    CustomTabBar(selectedTab: $selectedTab)
                        .zIndex(1)
                }
                // Tímto říkáme, že spodní část obrazovky (kde je TabBar) nemá být
                // ignorována obsahem, aby se obsah scrolloval "nad" spodní hranou,
                // ale CustomTabBar si to vyřeší sám přes edgesIgnoringSafeArea.
            }
            .onChange(of: selectedTab) { _, newValue in
                // Reload HomeView při návratu na něj (volitelné)
                if newValue == 0 {
                    homeReloadID = UUID()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct TabContentView: View {
    @Binding var selectedTab: Int
    @Binding var homeReloadID: UUID
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeContentView()
                    .id(homeReloadID)
            case 1:
                DungeonMapView()
            case 2:
                ActivityView()
            case 3:
                ShopView()
            case 4:
                ProfileView()
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
