//
//  HistoryView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 20.01.2026.
//


//
//  HistoryView.swift
//  DungeonStride
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userService: UserService
    
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(themeManager.accentColor)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.activities.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.secondaryTextColor)
                        Text("No activities found yet.")
                            .font(.headline)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.activities) { activity in
                                NavigationLink(destination: HistoryDetailView(activity: activity)) {
                                    HistoryRow(activity: activity)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Adventure Log")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let uid = authViewModel.currentUserUID {
                Task {
                    await viewModel.fetchHistory(for: uid)
                }
            }
        }
    }
}

struct HistoryRow: View {
    let activity: RunActivity
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        let units = userService.currentUser?.settings.units ?? .metric
        
        HStack(spacing: 16) {
            // Icon Background
            ZStack {
                Circle()
                    .fill(themeManager.backgroundColor)
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                
                Image(systemName: getActivityIcon(activity.type))
                    .foregroundColor(themeManager.accentColor)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.type.capitalized)
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Distance
                Text(units.formatDistance(Int(activity.distanceKm * 1000)))
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                // Duration
                Text(activity.duration.stringFormat())
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func getActivityIcon(_ type: String) -> String {
        switch type {
        case "Running": return "figure.run"
        case "Walking": return "figure.walk"
        case "Cycling": return "bicycle"
        default: return "figure.run"
        }
    }
}