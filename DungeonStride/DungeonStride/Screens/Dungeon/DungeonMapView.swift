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

    // Trigger pro centrování kamery (když se sem něco uloží, mapa tam odscroluje)
    @State private var cameraTarget: CGPoint?

    var body: some View {
        NavigationView {
            // Používáme náš nový ZoomableScrollView
            ZoomableScrollView(
                contentSize: CGSize(
                    width: viewModel.mapData?.width ?? 4000,
                    height: viewModel.mapData?.height ?? 4000
                ),
                centerOnPoint: $cameraTarget
            ) {
                ZStack(alignment: .topLeading) {

                    // 1. MAPA
                    if let mapInfo = viewModel.mapData {
                        Image(mapInfo.imageName)
                            .resizable()
                            .frame(width: mapInfo.width, height: mapInfo.height)
                    } else {
                        // Placeholder, než se načte
                        Color.black.frame(width: 4000, height: 4000)
                    }

                    // 2. LOKACE
                    ForEach(viewModel.locations) { location in
                        LocationMarkerView(location: location)
                            .position(location.position)
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }

                    // 3. USER AVATAR
                    if let user = viewModel.user {
                        UserAvatarView(user: user)
                            .position(viewModel.userPosition)
                            .id(user.id)  // Překreslení při změně
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
            .ignoresSafeArea()
            .navigationTitle("Ytonga")
            .navigationBarTitleDisplayMode(.inline)
            // Tlačítko pro manuální vycentrování (volitelné, ale užitečné)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        centerOnUser()
                    }) {
                        Image(systemName: "location.fill")
                    }
                }
            }
        }
        .task {
            // 1. Načíst data
            await viewModel.loadMapData(mapId: "map_ytonga_001")
            await viewModel.loadUser()

            // 2. Po krátké prodlevě (aby se stihl vykreslit layout) vycentrujeme na hráče
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s delay
            centerOnUser()
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailSheet(location: location, viewModel: viewModel)
                .presentationDetents([.fraction(0.40)])
                .presentationDragIndicator(.visible)
        }
        // Pokud hráč docestuje do cíle, chceme taky vycentrovat?
        .onChange(of: viewModel.isTraveling) { isTraveling in
            // Pokud začal cestovat nebo skončil, můžeme centrovat na něj
            if isTraveling {
                // Volitelné: Sledovat hráče kamerou během cesty
                // To by vyžadovalo posílat cameraTarget v timeru, což nedoporučuji pro výkon
            } else {
                // Až docestuje, vycentrujeme
                centerOnUser()
            }
        }
    }

    // Pomocná funkce pro vycentrování
    func centerOnUser() {
        // Získáme aktuální vizuální pozici hráče z ViewModelu
        let target = viewModel.userPosition

        // Nastavíme trigger, ZoomableScrollView to zachytí a provede animaci
        self.cameraTarget = target
    }
}
