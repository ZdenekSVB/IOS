//
//  QuestLibrary.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 10.11.2025.
//


//
//  QuestLibrary.swift
//  DungeonStride
//

import Foundation

struct QuestLibrary {
    static let all: [Quest] = [
        Quest(id: "steps_5000", title: "Morning Mover", description: "Walk 5,000 steps today", iconName: "figure.walk", xpReward: 80, requirement: .steps(5000)),
        Quest(id: "steps_10000", title: "Step Master", description: "Walk 10,000 steps today", iconName: "figure.walk", xpReward: 120, requirement: .steps(10000)),
        Quest(id: "steps_20000", title: "Step Legend", description: "Walk 20,000 steps in a day", iconName: "figure.walk.circle", xpReward: 200, requirement: .steps(20000)),
        Quest(id: "distance_3k", title: "Short Sprint", description: "Run 3 km today", iconName: "figure.run", xpReward: 100, requirement: .distance(3000)),
        Quest(id: "distance_5k", title: "Distance Runner", description: "Run 5 km", iconName: "road.lanes", xpReward: 150, requirement: .distance(5000)),
        Quest(id: "distance_10k", title: "Endurance Hero", description: "Run 10 km in a day", iconName: "figure.run.circle", xpReward: 250, requirement: .distance(10000)),
        Quest(id: "calories_300", title: "Fat Burner", description: "Burn 300 calories", iconName: "flame", xpReward: 80, requirement: .calories(300)),
        Quest(id: "calories_600", title: "Sweat Session", description: "Burn 600 calories", iconName: "flame.fill", xpReward: 120, requirement: .calories(600)),
        Quest(id: "calories_1000", title: "Inferno", description: "Burn 1,000 calories today", iconName: "flame.circle.fill", xpReward: 200, requirement: .calories(1000)),
        Quest(id: "runs_1", title: "Casual Runner", description: "Complete 1 run", iconName: "repeat", xpReward: 60, requirement: .runs(1)),
        Quest(id: "runs_2", title: "Double Dash", description: "Complete 2 runs", iconName: "repeat.circle", xpReward: 100, requirement: .runs(2)),
        Quest(id: "runs_3", title: "Triple Sprint", description: "Complete 3 runs", iconName: "repeat.circle.fill", xpReward: 150, requirement: .runs(3)),
        Quest(id: "login_2", title: "Consistent Strider", description: "Login for 2 consecutive days", iconName: "calendar", xpReward: 70, requirement: .dailyLogin(2)),
        Quest(id: "login_3", title: "Dedicated Adventurer", description: "Login for 3 days in a row", iconName: "calendar.circle", xpReward: 100, requirement: .dailyLogin(3)),
        Quest(id: "login_7", title: "Weekly Warrior", description: "Login for 7 consecutive days", iconName: "calendar.badge.clock", xpReward: 250, requirement: .dailyLogin(7)),
        Quest(id: "steps_30000", title: "Mega Mover", description: "Walk 30,000 steps", iconName: "figure.walk.motion", xpReward: 300, requirement: .steps(30000)),
        Quest(id: "distance_1k", title: "Warmup Run", description: "Run 1 km", iconName: "road.lanes", xpReward: 50, requirement: .distance(1000)),
        Quest(id: "distance_15k", title: "Marathon Prep", description: "Run 15 km", iconName: "figure.run.square.stack", xpReward: 300, requirement: .distance(15000)),
        Quest(id: "runs_5", title: "Persistent Runner", description: "Complete 5 runs", iconName: "arrow.triangle.2.circlepath", xpReward: 250, requirement: .runs(5)),
        Quest(id: "calories_1500", title: "Beast Mode", description: "Burn 1,500 calories", iconName: "flame.circle", xpReward: 300, requirement: .calories(1500)),
        Quest(id: "steps_8000", title: "Active Explorer", description: "Walk 8,000 steps", iconName: "figure.walk", xpReward: 90, requirement: .steps(8000)),
        Quest(id: "steps_12000", title: "Stride Streak", description: "Walk 12,000 steps", iconName: "figure.walk", xpReward: 130, requirement: .steps(12000)),
        Quest(id: "distance_7k", title: "Trailblazer", description: "Run 7 km", iconName: "figure.run", xpReward: 180, requirement: .distance(7000)),
        Quest(id: "distance_20k", title: "Half Marathoner", description: "Run 20 km", iconName: "figure.run.square.stack", xpReward: 400, requirement: .distance(20000)),
        Quest(id: "login_5", title: "Habit Builder", description: "Login 5 days in a row", iconName: "calendar.badge.exclamationmark", xpReward: 180, requirement: .dailyLogin(5)),
        Quest(id: "runs_10", title: "Tenacious Runner", description: "Complete 10 runs", iconName: "repeat.circle", xpReward: 400, requirement: .runs(10)),
        Quest(id: "calories_2000", title: "Energy Destroyer", description: "Burn 2,000 calories", iconName: "flame", xpReward: 350, requirement: .calories(2000)),
        Quest(id: "steps_15000", title: "Stride Champ", description: "Walk 15,000 steps", iconName: "figure.walk", xpReward: 180, requirement: .steps(15000)),
        Quest(id: "steps_25000", title: "Walking Machine", description: "Walk 25,000 steps", iconName: "figure.walk.circle.fill", xpReward: 250, requirement: .steps(25000)),
        Quest(id: "distance_12k", title: "Endurance Sprinter", description: "Run 12 km", iconName: "road.lanes", xpReward: 280, requirement: .distance(12000)),
        Quest(id: "runs_7", title: "Lucky Runner", description: "Complete 7 runs", iconName: "repeat.circle", xpReward: 300, requirement: .runs(7)),
        Quest(id: "calories_800", title: "Sweaty Hero", description: "Burn 800 calories", iconName: "flame", xpReward: 150, requirement: .calories(800)),
        Quest(id: "distance_25k", title: "Marathon Maniac", description: "Run 25 km", iconName: "figure.run.square.stack", xpReward: 450, requirement: .distance(25000)),
        Quest(id: "steps_40000", title: "Iron Legs", description: "Walk 40,000 steps", iconName: "figure.walk.motion", xpReward: 400, requirement: .steps(40000)),
        Quest(id: "runs_15", title: "Marathoner", description: "Complete 15 runs", iconName: "repeat.circle.fill", xpReward: 500, requirement: .runs(15)),
        Quest(id: "distance_2k", title: "Jog Beginner", description: "Run 2 km", iconName: "figure.run", xpReward: 70, requirement: .distance(2000)),
        Quest(id: "steps_6000", title: "Casual Walker", description: "Walk 6,000 steps", iconName: "figure.walk", xpReward: 75, requirement: .steps(6000)),
        Quest(id: "calories_400", title: "Light Burn", description: "Burn 400 calories", iconName: "flame", xpReward: 90, requirement: .calories(400)),
        Quest(id: "runs_4", title: "Quick Feet", description: "Complete 4 runs", iconName: "repeat", xpReward: 200, requirement: .runs(4)),
        Quest(id: "login_10", title: "Habit Master", description: "Login for 10 consecutive days", iconName: "calendar.badge.checkmark", xpReward: 400, requirement: .dailyLogin(10)),
        Quest(id: "distance_30k", title: "Ultra Runner", description: "Run 30 km", iconName: "figure.run", xpReward: 600, requirement: .distance(30000)),
        Quest(id: "calories_2500", title: "Fitness Freak", description: "Burn 2,500 calories", iconName: "flame.fill", xpReward: 500, requirement: .calories(2500)),
        Quest(id: "steps_35000", title: "Ultimate Walker", description: "Walk 35,000 steps", iconName: "figure.walk.circle", xpReward: 350, requirement: .steps(35000)),
        Quest(id: "runs_20", title: "Elite Runner", description: "Complete 20 runs", iconName: "repeat.circle.fill", xpReward: 600, requirement: .runs(20)),
        Quest(id: "login_14", title: "Two-Week Champion", description: "Login for 14 consecutive days", iconName: "calendar", xpReward: 500, requirement: .dailyLogin(14)),
        Quest(id: "distance_40k", title: "Trail King", description: "Run 40 km total", iconName: "road.lanes", xpReward: 700, requirement: .distance(40000)),
        Quest(id: "steps_50000", title: "Stride God", description: "Walk 50,000 steps", iconName: "figure.walk.circle.fill", xpReward: 500, requirement: .steps(50000)),
        Quest(id: "calories_3000", title: "Ultimate Burner", description: "Burn 3,000 calories", iconName: "flame.circle.fill", xpReward: 600, requirement: .calories(3000)),
        Quest(id: "runs_25", title: "Legendary Runner", description: "Complete 25 runs", iconName: "repeat.circle.fill", xpReward: 700, requirement: .runs(25)),
        Quest(id: "distance_50k", title: "Endurance God", description: "Run 50 km total", iconName: "figure.run.circle", xpReward: 800, requirement: .distance(50000))
    ]
}
