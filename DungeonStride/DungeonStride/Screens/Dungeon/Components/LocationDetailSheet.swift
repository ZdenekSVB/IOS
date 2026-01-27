//
//  LocationDetailSheet.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct LocationDetailSheet: View {
    let location: GameMapLocation
    @ObservedObject var viewModel: DungeonMapViewModel
    @Environment(\.dismiss) var dismiss

    var isCurrentLocation: Bool {
        return viewModel.currentUserLocation?.id == location.id
    }

    var iconName: String {
        switch location.locationType {
        case "city": return "house.fill"
        case "dungeon": return "skull_icon"
        case "ruins": return "building.columns.fill"
        case "swamp": return "drop.fill"
        default: return "mappin.circle.fill"
        }
    }

    var iconColor: Color {
        switch location.locationType {
        case "city": return .blue
        case "dungeon": return .red
        case "ruins": return .orange
        case "swamp": return .green
        default: return .gray
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    if location.locationType == "dungeon" {
                        Image("skull_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(iconColor)
                            .padding()
                            .background(iconColor.opacity(0.1))
                            .clipShape(Circle())
                            .padding(.top, 20)
                    } else {
                        Image(systemName: iconName)
                            .font(.system(size: 50))
                            .foregroundColor(iconColor)
                            .padding()
                            .background(iconColor.opacity(0.1))
                            .clipShape(Circle())
                            .padding(.top, 20)
                    }

                    Text(location.name)
                        .font(.title2).bold()

                    HStack {
                        Text(location.locationType.uppercased())
                            .font(.caption).fontWeight(.bold)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.secondary).cornerRadius(8)

                        if let tier = location.difficultyTier {
                            HStack(spacing: 2) {
                                ForEach(0..<tier, id: \.self) { _ in
                                    Image("skull_icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.leading, 8)
                        }
                    }
                }
                .padding(.top, 20)

                Divider()

                if isCurrentLocation
                    && (location.locationType == "dungeon"
                        || location.locationType == "swamp")
                {

                    // === DUNGEON ===

                    VStack(spacing: 15) {

                        if let desc = location.description {
                            Text(desc)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 10)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Divider()

                        DungeonMenuView(
                            location: location,
                            viewModel: viewModel
                        )
                    }

                } else {

                    ScrollView {
                        VStack(spacing: 16) {
                            Text(location.description ?? "Žádný popis.")
                                .font(.body).foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top)

                            if location.locationType == "ruins" {
                                HStack {
                                    Image(
                                        systemName: "exclamationmark.triangle"
                                    )
                                    Text("Nebezpečná oblast - Roguelike Mód")
                                }
                                .font(.subheadline)
                                .foregroundColor(.purple)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    VStack(spacing: 12) {

                        if isCurrentLocation {
                            if location.locationType == "ruins" {
                                Button(action: {
                                    dismiss()
                                    viewModel.enterRuins(location: location)
                                }) {
                                    HStack {
                                        Image(systemName: "flame.fill")
                                        Text("VSTOUPIT DO RUIN")
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white).cornerRadius(15)
                                }
                            } else {
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text("Nacházíš se zde")
                                    }
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.gray).cornerRadius(15)
                                }
                                .disabled(true)
                            }

                        } else if viewModel.isTraveling {
                            Button(action: {}) {
                                HStack {
                                    ProgressView().padding(.trailing, 8)
                                    Text("Cestuji...")
                                }
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white).cornerRadius(15)
                            }
                            .disabled(true)

                        } else {

                            let travelCost = viewModel.calculateTravelCost(
                                to: location
                            )
                            let userBank = viewModel.user?.distanceBank ?? 0.0
                            let canAfford = userBank >= travelCost

                            Button(action: {
                                if canAfford {
                                    dismiss()
                                    viewModel.travel(to: location)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "figure.walk")
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Cestovat sem")
                                            .fontWeight(.bold)

                                        Text(
                                            "Cena: \(formatDistance(travelCost))"
                                        )
                                        .font(.caption2)
                                        .opacity(0.9)
                                    }
                                }
                                .frame(maxWidth: .infinity).padding()
                                .background(canAfford ? Color.blue : Color.gray)
                                .foregroundColor(.white).cornerRadius(15)
                            }
                            .disabled(!canAfford)

                            if !canAfford {
                                Text(
                                    "Chybí ti \(formatDistance(travelCost - userBank)) energie."
                                )
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
            }

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(.systemGray3))
                    .padding(16)
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}
