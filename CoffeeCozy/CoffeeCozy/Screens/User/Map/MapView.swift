//
//  MapView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
            NavigationStack {
                Map(position: $viewModel.state.mapCameraPosition, interactionModes: [.pan, .zoom]) {
                    ForEach(viewModel.cafes) { cafe in
                        Annotation(
                            "",
                            coordinate: cafe.coordinates
                        ){
                            VStack(spacing: 5) {
                                Image(
                                    systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                 Text(cafe.name)
                                     .font(.caption2)
                                     .fixedSize()
                                }
                        }
                    }
                }
                .navigationTitle("Map")
                .edgesIgnoringSafeArea(.all)
            }
        }
}
