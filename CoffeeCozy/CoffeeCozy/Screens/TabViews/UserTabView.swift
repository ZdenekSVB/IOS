//
//  UserTabView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation

struct UserTabView: View {
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor(named: "Paleta2")

                // Barvy pro vybranou položku
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                UITabBar.appearance().tintColor = UIColor(named: "Paleta3")
                UITabBar.appearance().unselectedItemTintColor = UIColor.black 
        }
    
    var body: some View {
        TabView {
            SortimentView()
                .tabItem {
                    Label("Sortiment", systemImage: "cup.and.saucer")
                }

            HomeView()
                .tabItem {
                    Label("Domů", systemImage: "house")
                }

            OrdersView()
                .tabItem {
                    Label("Historie", systemImage: "clock")
                }
        }.toolbarBackground(.paleta2, for: .tabBar)
            .accentColor(.paleta3)
    }
}

