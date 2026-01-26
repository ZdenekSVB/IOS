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
                VStack(spacing: 10) {
                    Image(systemName: iconName)
                        .font(.system(size: 50))
                        .foregroundColor(iconColor)
                        .padding()
                        .background(iconColor.opacity(0.1))
                        .clipShape(Circle())

                    Text(location.name)
                        .font(.title2)
                        .bold()

                    Text(location.locationType.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.secondary)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

                Divider()

                ScrollView {
                    Text(location.description ?? "Žádný popis.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                if isCurrentLocation {
                    // 1. JSME NA MÍSTĚ

                    if location.locationType == "dungeon" {
                        // A) JE TO DUNGEON -> Zobrazíme Menu Monster
                        // Tady vložíme tu komponentu, kterou jsi posílal (DungeonMenuView)
                        Divider()
                        DungeonMenuView(
                            location: location,
                            viewModel: viewModel
                        )
                        .frame(maxHeight: 300)  // Omezíme výšku seznamu

                    } else {
                        // B) NENÍ TO DUNGEON (Město atd.) -> Klasické "Nacházíš se zde"
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("Nacházíš se zde")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.gray)
                            .cornerRadius(15)
                        }
                        .disabled(true)
                    }

                } else if viewModel.isTraveling {
                    // 2. CESTUJEME
                    Button(action: {}) {
                        HStack {
                            ProgressView().padding(.trailing, 8)
                            Text("Cestuji...")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(true)

                } else {
                    // 3. MŮŽEME CESTOVAT
                    Button(action: {
                        dismiss()
                        viewModel.travel(to: location)
                    }) {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Cestovat sem")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(.systemGray3))
                    .padding(16)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}
