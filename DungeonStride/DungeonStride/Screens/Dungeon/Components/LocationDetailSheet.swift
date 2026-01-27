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
        case "dungeon": return "skull.fill"
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
            VStack(spacing: 20) {
                // --- HLAVIČKA ---
                VStack(spacing: 10) {
                    Image(systemName: iconName)
                        .font(.system(size: 50))
                        .foregroundColor(iconColor)
                        .padding()
                        .background(iconColor.opacity(0.1))
                        .clipShape(Circle())

                    Text(location.name)
                        .font(.title2).bold()

                    // Typ lokace + Obtížnost
                    HStack {
                        Text(location.locationType.uppercased())
                            .font(.caption).fontWeight(.bold)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.secondary).cornerRadius(8)

                        // Zobrazení lebek podle difficultyTier
                        if let tier = location.difficultyTier {
                            HStack(spacing: 2) {
                                ForEach(0..<tier, id: \.self) { _ in
                                    Image(systemName: "skull.fill")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.leading, 8)
                        }
                    }
                }
                .padding(.top, 20)

                Divider()

                // --- POPIS ---
                ScrollView {
                    Text(location.description ?? "Žádný popis.")
                        .font(.body).foregroundColor(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }

                Spacer()

                // --- AKCE ---
                if isCurrentLocation {
                    // Jsme na místě
                    if location.locationType == "dungeon"
                        || location.locationType == "swamp"
                    {
                        Divider()
                        DungeonMenuView(
                            location: location,
                            viewModel: viewModel
                        )
                        .frame(maxHeight: 300)
                    } else if location.locationType == "ruins" {
                        // Tady později přidáme logiku Ruin (Dveře), zatím placeholder
                        Text("Ruiny - Brzy přístupné!")
                            .foregroundColor(.orange)
                            .padding()
                    } else {
                        // Město atd.
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
                    // Cestujeme
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
                    // Můžeme cestovat
                    Button(action: {
                        dismiss()
                        viewModel.travel(to: location)
                    }) {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Cestovat sem")
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.blue)
                        .foregroundColor(.white).cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)

            // Křížek
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(.systemGray3))
                    .padding(16)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}
