//
//  AdminTabView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI

struct AdminTabView: View {
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
            ASortimentView()
                .tabItem {
                    Label("Sortiment", systemImage: "cup.and.saucer.fill")
                }

            AUsersView()
                .tabItem {
                    Label("Users", systemImage: "person.3.fill")
                }

            AReportView()
                .tabItem {
                    Label("Reports", systemImage: "doc.text.magnifyingglass")
                }

            AOrdersView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        .environmentObject(authViewModel)
        .toolbarBackground(.paleta2)
        .accentColor(.paleta3)
    }
}
