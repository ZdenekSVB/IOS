//
//  QuestTemplates.swift
//  DungeonStride
//

import Foundation

struct QuestTemplates {
    static func generateQuests() -> [Quest] {
        var quests: [Quest] = []

        let stepGoals = [2000, 5000, 7500, 10000, 15000, 20000, 30000]
        let distanceGoals = [1000, 3000, 5000, 10000, 15000]
        let calorieGoals = [200, 400, 600, 800, 1000, 1500]
        let runGoals = [1, 2, 3, 5, 7]
        let loginGoals = [2, 3, 5, 7, 10]

        var idCounter = 1

        for s in stepGoals {
            quests.append(Quest(
                id: "steps_\(idCounter)",
                title: "Walk \(s) steps",
                description: "Complete \(s) steps in one day",
                iconName: "figure.walk",
                xpReward: max(50, s / 100),
                requirement: .steps(s)
            ))
            idCounter += 1
        }

        for d in distanceGoals {
            quests.append(Quest(
                id: "distance_\(idCounter)",
                title: "Run \(d >= 1000 ? "\(d/1000) km" : "\(d) m")",
                description: "Cover \(d >= 1000 ? "\(d/1000) km" : "\(d) m") during your activities",
                iconName: "road.lanes",
                xpReward: max(60, d / 50),
                requirement: .distance(d)
            ))
            idCounter += 1
        }

        for c in calorieGoals {
            quests.append(Quest(
                id: "calories_\(idCounter)",
                title: "Burn \(c) calories",
                description: "Burn \(c) calories",
                iconName: "flame",
                xpReward: max(40, c / 10),
                requirement: .calories(c)
            ))
            idCounter += 1
        }

        for r in runGoals {
            quests.append(Quest(
                id: "runs_\(idCounter)",
                title: "Complete \(r) runs",
                description: "Finish \(r) separate runs",
                iconName: "figure.run",
                xpReward: max(80, r * 120),
                requirement: .runs(r)
            ))
            idCounter += 1
        }

        for l in loginGoals {
            quests.append(Quest(
                id: "login_\(idCounter)",
                title: "Login for \(l) days",
                description: "Login for \(l) consecutive days",
                iconName: "calendar",
                xpReward: max(60, l * 50),
                requirement: .dailyLogin(l)
            ))
            idCounter += 1
        }

        // doplnit do ~50 questů kopií s unikátním id
        while quests.count < 50 {
            let base = quests.randomElement()!
            quests.append(Quest(
                id: "copy_\(idCounter)",
                title: base.title,
                description: base.description,
                iconName: base.iconName,
                xpReward: base.xpReward,
                requirement: base.requirement
            ))
            idCounter += 1
        }

        return quests
    }
}
