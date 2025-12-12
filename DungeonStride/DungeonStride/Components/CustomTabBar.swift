//
//  CustomTabBar.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
//


//
//  NavigationComponents.swift
//  DungeonStride
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            TabBarButton(icon: "door.left.hand.open", title: "Dungeon", isSelected: selectedTab == 0, themeManager: themeManager) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "chart.bar.fill", title: "Activity", isSelected: selectedTab == 1, themeManager: themeManager) {
                selectedTab = 1
            }
            
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 2, themeManager: themeManager) {
                selectedTab = 2
            }
            
            TabBarButton(icon: "cart.fill", title: "Shop", isSelected: selectedTab == 3, themeManager: themeManager) {
                selectedTab = 3
            }
            
            TabBarButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4, themeManager: themeManager) {
                selectedTab = 4
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(themeManager.cardBackgroundColor)
    }
}