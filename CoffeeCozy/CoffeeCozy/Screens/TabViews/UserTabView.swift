//
//  UserTabView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation

struct UserTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "Paleta2")
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(named: "Paleta3")
        UITabBar.appearance().unselectedItemTintColor = UIColor.black
    }
    
    var body: some View {
        TabView {
            SortimentView()
                .tabItem {
                    Label("Sortiment", systemImage: "list.bullet")
                }
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "cart")
                }
        }
        .environmentObject(authViewModel)
        .toolbarBackground(.paleta2)
        .accentColor(.paleta3)
    }
}
