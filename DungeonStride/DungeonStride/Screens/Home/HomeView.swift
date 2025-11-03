//
//  HomeView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


//
//  HomeView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 2 // Home je vybraný defaultně
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color("Paleta3")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Hlavní obsah
                    Group {
                        switch selectedTab {
                        case 0:
                            DungeonView()
                        case 1:
                            ActivityView()
                        case 2:
                            HomeContentView()
                        case 3:
                            ShopView()
                        case 4:
                            ProfileView()
                        default:
                            HomeContentView()
                        }
                    }
                    
                    // Bottom Navigation Bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}