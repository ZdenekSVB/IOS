//
//  TabContentView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI
import MapKit


struct TabContentView: View {
    @Binding var selectedTab: Int
    @Binding var homeReloadID: UUID
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeContentView()
                    .id(homeReloadID)
            case 1:
                DungeonMapView()
            case 2:
                ActivityView()
            case 3:
                ShopView()
            case 4:
                ProfileView()
            default:
                HomeContentView()
                    .id(homeReloadID)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
