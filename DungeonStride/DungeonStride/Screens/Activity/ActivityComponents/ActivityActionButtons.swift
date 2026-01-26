//
//  ActivityActionButtons.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit
import Charts
import CoreLocation
// MARK: - Control Buttons
struct ActivityActionButtons: View {
    @ObservedObject var activityManager: ActivityManager
    var authViewModel: AuthViewModel
    var userService: UserService
    @EnvironmentObject var questService: QuestService
    
    var body: some View {
        HStack(spacing: 20) {
            // START / PAUSE
            Button {
                if activityManager.activityState == .active {
                    
                    activityManager.pauseActivity()
                } else {
                    activityManager.startActivity()
                }
            } label: {
                Image(systemName: activityManager.activityState == .active ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(activityManager.activityState == .active ? Color.orange : Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            
            // STOP
            if activityManager.activityState == .active || activityManager.activityState == .paused {
                Button {
                    activityManager.finishActivity(
                        userId: authViewModel.currentUserUID,
                        userService: userService,
                        questService: questService
                    )
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // RESET
            if activityManager.activityState == .finished {
                Button {
                    activityManager.resetActivity()
                } label: {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: activityManager.activityState)
    }
}
