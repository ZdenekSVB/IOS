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
    
    @State private var selectedTab = 2
    @State private var homeReloadID = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TabContentView(selectedTab: $selectedTab, homeReloadID: $homeReloadID)
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 2 {
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
                
                // --- DEV BUTTON (Zakomentováno) ---
                /*
                Button(action: {
                    print("🚀 Spouštím seedování questů...")
                    DatabaseSeeder().uploadQuestsToFirestore()
                }) {
                    Text("SEED QUESTS (DEV ONLY)")
                        .font(.caption)
                        .bold()
                        .padding(8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                */
                // ----------------------------------
                
                UserProgressCard()
                LastRunCard(lastActivity: lastActivity)
                QuestsCard()
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
