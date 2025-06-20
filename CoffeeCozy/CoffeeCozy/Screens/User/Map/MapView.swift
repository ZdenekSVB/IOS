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
    @State var isDetailPresented = false
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
            NavigationStack {
                Map(position: $viewModel.state.mapCameraPosition, interactionModes: [.pan, .zoom]) {
                    ForEach(viewModel.state.cafes) { cafe in
                        Annotation(
                            "",
                            coordinate: cafe.coordinates
                        ){
                            
                        }
                    }
                }
                .navigationTitle("Brno Map")
                .edgesIgnoringSafeArea(.all)
            }
        }
}
