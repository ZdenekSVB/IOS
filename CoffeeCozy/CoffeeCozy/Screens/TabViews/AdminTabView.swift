//
//  AdminTabView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation

struct AdminTabView: View {
    
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
            ASortimentView()
                .tabItem {
                    Label("Sortiment", systemImage: "cup.and.saucer.fill")
                }

            AUsersView()
                .tabItem {
                    Label("Uživatelé", systemImage: "person.3.fill")
                }

            AReportView()
                .tabItem {
                    Label("Reporty", systemImage: "doc.text.magnifyingglass")
                }

            AOrdersView()
                .tabItem {
                    Label("Historie", systemImage: "clock.arrow.circlepath")
                }
        }.toolbarBackground(.paleta2)
            .accentColor(.paleta3)
            
        
    }
}

