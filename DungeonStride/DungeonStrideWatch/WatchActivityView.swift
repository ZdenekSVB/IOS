//
//  WatchActivityView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 19.01.2026.
//


//
//  WatchActivityView.swift
//  DungeonStride Watch App
//

import SwiftUI
import HealthKit

struct WatchActivityView: View {
    @StateObject private var workoutManager = WatchWorkoutManager()
    
    var body: some View {
        TabView {
            // Obrazovka 1: Metriky
            VStack(alignment: .leading, spacing: 8) {
                if workoutManager.running {
                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                        VStack(alignment: .leading) {
                            Text(formatElapsedTime(workoutManager.builder?.elapsedTime(at: context.date) ?? 0))
                                .font(.system(size: 32, weight: .bold).monospacedDigit())
                                .foregroundColor(.yellow)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("DISTANCE")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.2f km", workoutManager.distance / 1000))
                                        .font(.system(size: 20, weight: .semibold).monospacedDigit())
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("BPM")
                                        .font(.system(size: 10))
                                        .foregroundColor(.red)
                                    Text("\(Int(workoutManager.heartRate))")
                                        .font(.system(size: 20, weight: .semibold).monospacedDigit())
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("ENERGY")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                    Text("\(Int(workoutManager.activeEnergy)) kcal")
                                        .font(.system(size: 16, weight: .regular))
                                }
                            }
                        }
                    }
                } else {
                    // Startovací obrazovka
                    VStack {
                        Text("Ready to Start?")
                            .font(.headline)
                        
                        Picker("Activity", selection: $workoutManager.selectedActivity) {
                            ForEach(ActivityType.allCases) { type in
                                // Zobrazíme jen ikonku kvůli místu
                                Image(systemName: iconFor(type: type)).tag(type)
                            }
                        }
                        .frame(height: 50)
                        
                        Button(action: {
                            workoutManager.startWorkout(activityType: workoutManager.selectedActivity)
                        }) {
                            Text("START")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        .background(Color.green)
                        .cornerRadius(20)
                    }
                }
            }
            .padding()
            .tag(0)
            
            // Obrazovka 2: Ovládání (jen když běží)
            if workoutManager.running {
                VStack(spacing: 20) {
                    Button(action: {
                        workoutManager.endWorkout()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("End Run")
                        }
                    }
                    .tint(.red)
                    
                    Text("Swipe left for stats")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .tag(1)
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
    
    func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? "0:00:00"
    }
    
    func iconFor(type: ActivityType) -> String {
        switch type {
        case .run: return "figure.run"
        case .cycle: return "bicycle"
        case .swim: return "figure.pool.swim"
        case .kayak: return "figure.sailing"
        }
    }
}