//
//  CustomTabBar.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


//
//  CustomTabBar.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabBarButton(icon: "door.left.hand.open", title: "Dungeon", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "chart.bar.fill", title: "Activity", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabBarButton(icon: "cart.fill", title: "Shop", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            
            TabBarButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("Paleta5"))
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(2))
            .previewLayout(.sizeThatFits)
    }
}