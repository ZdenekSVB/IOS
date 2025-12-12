//
//  ActivityView.swift
//  DungeonStride
//

import SwiftUI
import CoreLocation

struct ActivityView: View {
    
    @StateObject private var activityManager: ActivityManager
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userService: UserService
    
    init() {
        _activityManager = StateObject(wrappedValue: DIContainer.shared.resolve())
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ActivityMapView(polylineCoordinates: $activityManager.currentPolyline, region: $activityManager.currentRegion)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding([.horizontal, .top])
                
                Picker("Typ aktivity", selection: $activityManager.selectedActivity) {
                    ForEach(ActivityType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .disabled(activityManager.activityState == .active || activityManager.activityState == .paused)
                
                MetricsView(activityManager: activityManager, themeManager: themeManager)
                
                PaceChart(activityManager: activityManager, themeManager: themeManager)
                    .frame(height: 150)
                    .padding()
                
                Spacer()
                
                ActivityActionButtons(
                    activityManager: activityManager,
                    authViewModel: authViewModel,
                    userService: userService
                )
                .padding(.bottom, 20)
            }
            
            if let error = activityManager.locationError {
                ErrorOverlay(message: error)
            }
        }
        .navigationTitle("Aktivita")
        .navigationBarTitleDisplayMode(.inline)
    }
}
