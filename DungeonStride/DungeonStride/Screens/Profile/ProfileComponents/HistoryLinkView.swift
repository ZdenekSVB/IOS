//
//  HistoryLinkView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct HistoryLinkView: View {
    let themeManager: ThemeManager
    
    var body: some View {
        NavigationLink(destination: HistoryView()) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(themeManager.accentColor)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("Activity History")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    Text("View your past runs and stats")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding()
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}
