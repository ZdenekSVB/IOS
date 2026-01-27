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

    // Defaultně vybraná záložka 2 (Home - střední)
    // Pokud chceš startovat na Home, zvaž změnu indexů,
    // aby Home byl uprostřed (např. 0,1,[2],3,4) nebo vlevo (0).
    // Podle tvého switch/case v TabContentView:
    // 0=Home, 1=Map, 2=Activity, 3=Shop, 4=Profile.
    // Dle zvyklostí bývá Activity uprostřed.
    // Upravil jsem default na 0 (Home), jak jsi měl v původním kódu.
    @State private var selectedTab = 0
    @State private var homeReloadID = UUID()

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {

                    // --- DEV BUTTON (Zakomentováno) ---
                    
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
                    
                    // ----------------------------------

                    // Obsah záložek
                    TabContentView(
                        selectedTab: $selectedTab,
                        homeReloadID: $homeReloadID
                    )

                    // Vlastní spodní lišta
                    // zIndex(1) zajistí, že vyčuhující tlačítko "Run" bude vizuálně NAD obsahem stránky
                    CustomTabBar(selectedTab: $selectedTab)
                        .zIndex(1)
                }
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
