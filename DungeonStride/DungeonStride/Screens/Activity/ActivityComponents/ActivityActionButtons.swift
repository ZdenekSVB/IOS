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
    
    // Pro kontrolu nastavení (zvuky/haptika)
    var hapticsEnabled: Bool { userService.currentUser?.settings.hapticsEnabled ?? true }
    var soundEnabled: Bool { userService.currentUser?.settings.soundEffectsEnabled ?? true }
    
    var body: some View {
        HStack(spacing: 20) {
            // START / PAUSE
            Button {
                // Haptika & Zvuk
                HapticManager.shared.mediumImpact(enabled: hapticsEnabled)
                if soundEnabled { SoundManager.shared.playSystemClick() }
                
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
                    // Haptika (Silnější pro STOP) & Zvuk
                    HapticManager.shared.heavyImpact(enabled: hapticsEnabled)
                    if soundEnabled { SoundManager.shared.playSystemSuccess() } // Nebo jiný zvuk konce
                    
                    activityManager.finishActivity(
                        userId: authViewModel.currentUserUID,
                        userService: userService,
                        questService: questService,
                        currentUser: userService.currentUser
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
                    // Haptika & Zvuk
                    HapticManager.shared.warning(enabled: hapticsEnabled)
                    if soundEnabled { SoundManager.shared.playSystemClick() }
                    
                    activityManager.resetActivity()
                } label: {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                        // Lokalizovaný text
                        Text("Reset", comment: "Label for reset button on activity screen")
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
