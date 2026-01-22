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
            // 1. HOME
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 0, themeManager: themeManager) {
                selectedTab = 0
            }
            
            // 2. DUNGEON
            TabBarButton(icon: "map.fill", title: "Dungeon", isSelected: selectedTab == 1, themeManager: themeManager) {
                selectedTab = 1
            }
            
            // 3. RUN (Hero Button)
            ZStack {
                // Kruhové pozadí tlačítka
                Circle()
                    .fill(themeManager.accentColor)
                    .frame(width: 60, height: 60)
                    .shadow(color: themeManager.accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                
                // Ikona
                Image(systemName: "figure.run")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            .offset(y: -25) // Vyčuhuje nahoru mimo lištu
            .onTapGesture {
                selectedTab = 2
            }
            .frame(width: 60) // Rezervuje místo v HStacku, aby se ostatní tlačítka nerozjela
            
            // 4. SHOP
            TabBarButton(icon: "cart.fill", title: "Shop", isSelected: selectedTab == 3, themeManager: themeManager) {
                selectedTab = 3
            }
            
            // 5. PROFILE
            TabBarButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4, themeManager: themeManager) {
                selectedTab = 4
            }
        }
        .padding(.top, 12) // Vnitřní odsazení shora, aby texty nebyly nalepené na hraně
        .padding(.bottom, 8) // Jemné odsazení od spodního okraje (pro vizuální balanc)
        .padding(.horizontal, 10)
        .background(
            // Pozadí definujeme zde odděleně
            themeManager.cardBackgroundColor
                // Ořízneme jen horní rohy
                .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))
                // Stín vrhneme jen pod pozadí
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
                // DŮLEŽITÉ: Roztáhneme pozadí až úplně dolů přes Safe Area
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}

// Pomocná struktura pro kulaté rohy jen na vybraných stranách
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
