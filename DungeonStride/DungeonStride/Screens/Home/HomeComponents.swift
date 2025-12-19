//
//  HomeComponents.swift
//  DungeonStride
//

import SwiftUI
import MapKit

// MARK: - User Progress Card
struct UserProgressCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Avatar
                if let avatar = userService.currentUser?.selectedAvatar {
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(themeManager.accentColor)
                }
                
                VStack(alignment: .leading) {
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                    // Zobrazujeme Username
                    Text(userService.currentUser?.username ?? "Adventurer")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Spacer()
                
                // Level Badge
                VStack {
                    Text("Lvl")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("\(userService.currentUser?.level ?? 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            // XP Progress
            if let user = userService.currentUser {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next Level")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                        Text("\(user.totalXP) / \(user.level * 100) XP")
                            .font(.caption)
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(themeManager.cardBackgroundColor.opacity(0.5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(themeManager.accentColor)
                                .frame(width: min(geometry.size.width * CGFloat(user.levelProgress), geometry.size.width), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Last Run Card
struct LastRunCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    // Přijímáme data zvenčí
    let lastActivity: RunActivity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Last Activity")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                if let activity = lastActivity {
                    Text(activity.timeAgo)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            if let activity = lastActivity {
                ZStack {
                    // --- ZOBRAZENÍ MAPY ---
                    if let coords = activity.routeCoordinates, !coords.isEmpty {
                        // Zobrazíme mapu s vypočítaným regionem
                        ActivityMapView(
                            polylineCoordinates: .constant(coords),
                            region: .constant(calculateRegion(for: coords))
                        )
                        .frame(height: 150)
                        .cornerRadius(8)
                        .disabled(true) // Aby mapa nebrala dotyky (byla jen jako obrázek)
                        
                    } else {
                        // Fallback, pokud nejsou souřadnice
                        Rectangle()
                            .fill(themeManager.secondaryTextColor.opacity(0.3))
                            .frame(height: 150)
                            .cornerRadius(8)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeManager.accentColor)
                    }
                    
                    // Štítek typu aktivity
                    VStack {
                        Spacer()
                        HStack {
                            Text(activity.type.capitalized)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                .frame(height: 150) // Fixní výška
                
                let units = userService.currentUser?.settings.units ?? .metric
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatItem(
                        icon: "figure.walk",
                        title: "Distance",
                        value: units.formatDistance(Int(activity.distanceKm * 1000))
                    )
                    StatItem(
                        icon: "flame.fill",
                        title: "Calories",
                        value: "\(activity.calories)"
                    )
                    StatItem(
                        icon: "timer",
                        title: "Duration",
                        value: activity.duration.stringFormat()
                    )
                    StatItem(
                        icon: "speedometer",
                        title: "Pace",
                        value: formatPace(activity.pace, unit: units)
                    )
                }
            } else {
                // Empty State
                VStack(spacing: 10) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("No activities yet")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Text("Go to Activity tab to start your first run!")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func formatPace(_ paceMinKm: Double, unit: DistanceUnit) -> String {
        if unit == .metric {
            return String(format: "%.2f min/km", paceMinKm)
        } else {
            return String(format: "%.2f min/mi", paceMinKm * 1.60934)
        }
    }
    
    /// Vypočítá střed a zoom mapy tak, aby byla vidět celá trasa
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.4, // Trochu bufferu
            longitudeDelta: (maxLon - minLon) * 1.4
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Quests Card
struct QuestsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var questService: QuestService
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Quests")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Spacer()
                
                if questService.isLoading {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Text("\(questService.dailyQuests.filter { $0.isCompleted }.count)/\(questService.dailyQuests.count)")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            if questService.isLoading {
                ProgressView("Loading quests...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if questService.dailyQuests.isEmpty {
                Text("No quests available today")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(questService.dailyQuests) { quest in
                        // Pouze zobrazujeme, žádná akce onComplete z UI
                        QuestRow(quest: quest)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
        .onChange(of: userService.currentUser?.uid) { _, _ in
            loadQuests()
        }
    }
    
    private func loadQuests() {
        guard let userId = userService.currentUser?.uid else { return }
        Task {
            try? await questService.loadDailyQuests(for: userId)
        }
    }
}

struct QuestRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quest: Quest
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.iconName)
                .font(.title3)
                .foregroundColor(quest.isCompleted ? .green : themeManager.accentColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(quest.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.primaryTextColor)
                    Spacer()
                    
                    if quest.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
                
                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
                
                ProgressView(value: quest.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: quest.isCompleted ? .green : themeManager.accentColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                
                HStack {
                    Text("\(quest.progress)/\(quest.totalRequired)")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                    Spacer()
                    Text("+\(quest.xpReward) XP")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Helper pro statistiky v LastRunCard (aby se kód neopakoval)
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(themeManager.accentColor)
                Text(title)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.primaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(themeManager.backgroundColor.opacity(0.5))
        .cornerRadius(8)
    }
}
