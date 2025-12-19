//
//  ActivityView.swift
//  DungeonStride
//

import SwiftUI
import CoreLocation

struct ActivityView: View {
    
    // Používáme standardní StateObject pro instanci
    @StateObject private var activityManager = ActivityManager()
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userService: UserService
    // Přidáno QuestService, aby bylo dostupné pro ActivityActionButtons
    @EnvironmentObject var questService: QuestService
    
    var body: some View {
        let currentUnits = userService.currentUser?.settings.units ?? .metric
        let isNautical = currentUnits == .nautical
        
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header (Toggle & Picker)
                HStack(spacing: 12) {
                    TerrainToggleButton(isNautical: isNautical, themeManager: themeManager) {
                        toggleTerrain(current: currentUnits)
                    }
                    
                    Picker("Activity Type", selection: $activityManager.selectedActivity) {
                        if isNautical {
                            ForEach(ActivityType.waterActivities) { type in
                                Text(type.rawValue).tag(type)
                            }
                        } else {
                            ForEach(ActivityType.landActivities) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(themeManager.cardBackgroundColor)
                .disabled(activityManager.activityState == .active || activityManager.activityState == .paused)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Map
                        ActivityMapView(polylineCoordinates: $activityManager.currentPolyline, region: $activityManager.currentRegion)
                            .frame(height: 250)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        // MARK: - Metrics & Chart
                        VStack(spacing: 20) {
                            MetricsView(
                                activityManager: activityManager,
                                themeManager: themeManager,
                                units: currentUnits
                            )
                            
                            Divider()
                                .background(themeManager.secondaryTextColor.opacity(0.3))
                            
                            PaceChart(
                                activityManager: activityManager,
                                themeManager: themeManager,
                                units: currentUnits
                            )
                            .frame(height: 180)
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(16)
                    }
                    .padding()
                }
                
                // MARK: - Bottom Controls
                VStack {
                    ActivityActionButtons(
                        activityManager: activityManager,
                        authViewModel: authViewModel,
                        userService: userService
                    )
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .background(themeManager.backgroundColor.ignoresSafeArea(edges: .bottom))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
            
            if let error = activityManager.locationError {
                ErrorOverlay(message: error)
            }
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            activityManager.validateActivityType(for: currentUnits)
        }
        .onChange(of: currentUnits) { newUnit, _ in
            activityManager.validateActivityType(for: newUnit)
        }
    }
    
    private func toggleTerrain(current: DistanceUnit) {
        guard let uid = authViewModel.currentUserUID else { return }
        
        let newUnit: DistanceUnit = (current == .nautical) ? .metric : .nautical
        
        let newSettings = UserSettings(
            isDarkMode: themeManager.isDarkMode,
            notificationsEnabled: userService.currentUser?.settings.notificationsEnabled ?? true,
            soundEffectsEnabled: userService.currentUser?.settings.soundEffectsEnabled ?? true,
            units: newUnit
        )
        
        Task {
            try? await userService.updateUserSettings(uid: uid, settings: newSettings)
        }
    }
}
