//
//  HistoryListContent.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit

struct HistoryListContent: View {
    @ObservedObject var viewModel: HistoryViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.activities.isEmpty {
                emptyView
            } else {
                activitiesList
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView().tint(themeManager.accentColor)
            Spacer()
        }
    }
    
    private func errorView(_ error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
            .padding()
    }
    
    private var emptyView: some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryTextColor)
            Text("Zatím žádné aktivity.")
                .font(.headline)
                .foregroundColor(themeManager.secondaryTextColor)
            Spacer()
        }
    }
    
    private var activitiesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let items = viewModel.filteredActivities
                
                if items.isEmpty {
                    Text("V tomto rozmezí nejsou žádné aktivity.")
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(.top, 40)
                } else {
                    ForEach(items) { activity in
                        NavigationLink(destination: HistoryDetailView(activity: activity)) {
                            HistoryRow(activity: activity)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
