//
//  DungeonMapView.swift
//  DungeonStride
//
//  Created by Vit Cevelik on 03.11.2025.
//

import SwiftUI
import UIKit

struct DungeonMapView: View {
    @StateObject var viewModel = DungeonMapViewModel()
    @State private var selectedLocation: GameMapLocation?
    @State private var cameraTarget: CGPoint?

    @State private var showCharacterView = false

    @State private var showActivityTracker = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                ZoomableScrollView(
                    contentSize: CGSize(
                        width: viewModel.mapData?.width ?? 4000,
                        height: viewModel.mapData?.height ?? 4000
                    ),
                    centerOnPoint: $cameraTarget
                ) {
                    ZStack(alignment: .topLeading) {
                        if let mapInfo = viewModel.mapData {
                            Image(mapInfo.imageName)
                                .resizable()
                                .frame(
                                    width: mapInfo.width,
                                    height: mapInfo.height
                                )
                        }

                        ForEach(viewModel.locations) { location in
                            LocationMarkerView(location: location)
                                .position(location.position)
                                .onTapGesture { selectedLocation = location }
                        }

                        if let user = viewModel.user {
                            UserAvatarView(user: user)
                                .position(
                                    x: viewModel.userPosition.x + 40,
                                    y: viewModel.userPosition.y - 20
                                )
                                .id(user.id)
                                .allowsHitTesting(false)

                                .animation(
                                    viewModel.isTraveling
                                        ? .easeInOut(
                                            duration: viewModel
                                                .currentTravelDuration
                                        ) : nil,
                                    value: viewModel.userPosition
                                )
                        }
                    }
                }

                VStack {
                    HStack(alignment: .top) {

                        if let user = viewModel.user {
                            VStack(alignment: .leading, spacing: 8) {

                                Button(action: { showCharacterView = true }) {
                                    HStack(spacing: 6) {
                                        Image(user.selectedAvatar)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(
                                                    Color.white,
                                                    lineWidth: 2
                                                )
                                            )
                                            .shadow(radius: 4)

                                        VStack(alignment: .leading, spacing: 0)
                                        {
                                            Text(user.username)
                                                .font(.caption).bold()
                                                .foregroundColor(.black)
                                                .shadow(
                                                    color: .white,
                                                    radius: 2
                                                )

                                            Text("Lvl \(user.level)")
                                                .font(.caption2).bold()
                                                .foregroundColor(.blue)
                                                .shadow(
                                                    color: .white,
                                                    radius: 2
                                                )
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.85))
                                    .cornerRadius(30)
                                    .shadow(radius: 3)
                                }

                                HStack(spacing: 6) {
                                    Image(systemName: "shoeprints.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)

                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Energie")
                                            .font(.system(size: 8))
                                            .foregroundColor(.secondary)
                                        Text(formatDistance(user.distanceBank))
                                            .font(.caption).bold()
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(15)
                                .shadow(radius: 2)
                                .padding(.leading, 4)
                            }
                        }

                        Spacer()

                        Button(action: { centerOnUser() }) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(12)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 60)

                    Spacer()
                }

                if viewModel.isRuinsActive {
                    RuinsView(viewModel: viewModel)
                        .zIndex(50)
                        .transition(.opacity)
                }

                if let user = viewModel.user, user.isDead {
                    RevivalView(
                        user: Binding(
                            get: { viewModel.user! },
                            set: { viewModel.user = $0 }
                        ),
                        onRevive: {
                            viewModel.respawnUser()
                        }
                    )
                    .zIndex(100)  // Musí být nad mapou
                    .transition(.opacity)
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadMapData(mapId: "map_ytonga_001")
            await viewModel.loadUser()
            try? await Task.sleep(nanoseconds: 500_000_000)
            centerOnUser()
        }
        .onAppear {
            print("👁️ DungeonMap onAppear - reloading user data")
            Task {
                await viewModel.loadUser()
            }
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailSheet(location: location, viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCharacterView) {
            ZStack(alignment: .topTrailing) {
                CharacterView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $viewModel.showCombat) {
            if let user = viewModel.user, let enemy = viewModel.currentEnemy {
                CombatView(
                    viewModel: CombatViewModel(
                        player: user,
                        enemy: enemy,
                        onWin: {
                            print(
                                "🏆 Hráč vyhrál, aktualizuji DungeonProgress..."
                            )
                            viewModel.handleVictory()

                            if viewModel.isRuinsActive {
                                viewModel.prepareNextRoom()
                            }
                        }
                    )
                )
            } else {
                VStack {
                    Text("Chyba při načítání souboje")
                    Button("Zavřít") { viewModel.showCombat = false }
                }
            }
        }
        .onChange(of: viewModel.showCombat) { wasShown, isNowShown in
            if !isNowShown {
                print("🏁 Souboj skončil. Aktualizuji stav hráče...")
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    await viewModel.loadUser()
                }
            }
        }
        .onChange(of: viewModel.isTraveling) { _, isTraveling in
            if !isTraveling { centerOnUser() }
        }
    }

    func centerOnUser() {
        let target = viewModel.userPosition

        self.cameraTarget = target
    }

    func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}
