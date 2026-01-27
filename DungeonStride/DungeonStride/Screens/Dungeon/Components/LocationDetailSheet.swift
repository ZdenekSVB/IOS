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
                            .foregroundColor(iconColor)  // Funguje, pokud je obrázek "Render As: Template"
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

                    // === VARIANTA DUNGEON ===
                    // Zobrazíme Popis + Seznam hned pod sebou

                    VStack(spacing: 15) {  // Mezera mezi popisem a seznamem je jen 15 bodů

                        // A) Popis (pokud existuje)
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
                        Text(location.description ?? "Žádný popis.")
                            .font(.body).foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()

                        if location.locationType == "ruins" {
                            Text("Ruiny - Brzy přístupné!")
                                .foregroundColor(.orange)
                                .padding()
                        }
                    }

                    Spacer()  // Tlačí tlačítka dolů

                    // Tlačítka akcí
                    VStack {
                        if isCurrentLocation {
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
                    .padding()
                    .padding(.bottom, 10)
                }
            }
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
