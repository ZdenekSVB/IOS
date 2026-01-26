//
//  CustomTabBar.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    // Pro kontrolu nastavení (zvuky/haptika)
    // Zde nemáme přímý přístup k UserSettings, ale můžeme předpokládat default nebo si je vytáhnout z DI,
    // případně přidat EnvironmentObject UserService. Pro jednoduchost voláme HapticManager,
    // který má metodu s parametrem enabled (ten bychom měli ideálně získat).
    // Pokud nechceme komplikovat, necháme to vibrovat vždy (systémová haptika je jemná).
    
    var body: some View {
        HStack {
            // 1. HOME
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 0, themeManager: themeManager) {
                switchTab(to: 0)
            }
            
            // 2. DUNGEON
            TabBarButton(icon: "map.fill", title: "Dungeon", isSelected: selectedTab == 1, themeManager: themeManager) {
                switchTab(to: 1)
            }
            
            // 3. RUN (Hero Button)
            ZStack {
                Circle()
                    .fill(themeManager.accentColor)
                    .frame(width: 60, height: 60)
                    .shadow(color: themeManager.accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                
                Image(systemName: "figure.run")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            .offset(y: -25)
            .onTapGesture {
                switchTab(to: 2)
            }
            .frame(width: 60)
            
            // 4. SHOP
            TabBarButton(icon: "cart.fill", title: "Shop", isSelected: selectedTab == 3, themeManager: themeManager) {
                switchTab(to: 3)
            }
            
            // 5. PROFILE
            TabBarButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4, themeManager: themeManager) {
                switchTab(to: 4)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(
            themeManager.cardBackgroundColor
                .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
    
    // Pomocná funkce pro přepnutí s efekty
    private func switchTab(to index: Int) {
        if selectedTab != index {
            HapticManager.shared.mediumImpact() // Střední vibrace při změně tabu
            SoundManager.shared.playSystemClick()
            selectedTab = index
        }
    }
}
