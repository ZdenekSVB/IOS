//
//  CustomTabBar.swift
//  DungeonStride
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            // 0: Dungeon
            TabBarButton(icon: "door.left.hand.open", title: "Dungeon", isSelected: selectedTab == 0, themeManager: themeManager) {
                selectedTab = 0
            }
            
            // 1: Activity (Start Run)
            TabBarButton(icon: "figure.run", title: "Run", isSelected: selectedTab == 1, themeManager: themeManager) {
                selectedTab = 1
            }
            
            // 2: Home
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 2, themeManager: themeManager) {
                selectedTab = 2
            }
            
            // 5: History (NOVÉ - Index 5)
            // Dávám to sem, aby to bylo blízko Home a Aktivity, ale pořadí si můžeš změnit
            TabBarButton(icon: "clock.arrow.circlepath", title: "History", isSelected: selectedTab == 5, themeManager: themeManager) {
                selectedTab = 5
            }
            
            // 3: Shop
            TabBarButton(icon: "cart.fill", title: "Shop", isSelected: selectedTab == 3, themeManager: themeManager) {
                selectedTab = 3
            }
            
            // 4: Profile
            TabBarButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4, themeManager: themeManager) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 5) // Menší padding, aby se tam vešlo 6 ikon
        .padding(.vertical, 8)
        .background(themeManager.cardBackgroundColor)
    }
}
