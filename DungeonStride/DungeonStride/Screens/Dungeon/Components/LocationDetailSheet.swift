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
    @Environment(\.dismiss) var dismiss // Pro zavření okna po kliknutí
    
    // Zjištění, zda uživatel stojí na této lokaci
    var isCurrentLocation: Bool {
        // Porovnáváme ID nebo názvy, pokud equatable funguje správně
        return viewModel.currentUserLocation?.id == location.id
    }
    
    // Pomocná logika pro ikonu (stejná jako na mapě, ale větší)
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
        VStack(spacing: 20) {
            
            // --- HLAVIČKA (Ikona + Název) ---
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
                
                // Štítek s typem lokace
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
            
            // --- POPIS ---
            ScrollView {
                Text(location.description ?? "O tomto místě nejsou žádné záznamy.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // --- AKČNÍ TLAČÍTKO ---
            if isCurrentLocation {
                // VARIANTA 1: Uživatel už tu je
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
                
            } else if viewModel.isTraveling {
                // VARIANTA 2: Uživatel právě někam cestuje (blokujeme změnu cíle)
                Button(action: {}) {
                    HStack {
                        ProgressView()
                            .padding(.trailing, 8)
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
                // VARIANTA 3: Můžeme cestovat
                Button(action: {
                    dismiss() // Zavřeme sheet
                    viewModel.travel(to: location) // Spustíme logiku ve ViewModelu
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
                    .shadow(radius: 5)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .background(Color(UIColor.systemBackground))
    }
}
