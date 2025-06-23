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
    
    let selectionMode: Bool
    var onSelect: ((Cafe) -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
        @State private var selectedCafe: Cafe?
    
    init(viewModel: MapViewModel, selectionMode: Bool = false, onSelect: ((Cafe) -> Void)? = nil) {
            self.viewModel = viewModel
            self.selectionMode = selectionMode
            self.onSelect = onSelect
        }
    
    var body: some View {
            NavigationStack {
                Map(
                    position: $viewModel.state.mapCameraPosition,
                    interactionModes: [.pan, .zoom]) {
                        ForEach(viewModel.state.cafes) { cafe in
                            Annotation("", coordinate: cafe.coordinates) {
                                CafeAnnotationView(
                                    cafe: cafe,
                                    selectionMode: selectionMode,
                                    onSelect: { selectedCafe in
                                        viewModel.state.selectedCafe = selectedCafe
                                    }
                                )
                                .onTapGesture {
                                    if selectionMode {
                                        viewModel.state.selectedCafe = cafe
                                    }
                                }
                        }
                    }
                }
                .toolbar {
                    if selectionMode {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                if let selectedCafe {
                                    onSelect?(selectedCafe)
                                }
                                dismiss()
                            }
                            .disabled(selectedCafe == nil)
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchCafes()
                    viewModel.syncLocation()
                    
                    Task{
                        await viewModel.startPeriodicLocationUpdate()
                    }
                }
                .navigationTitle(selectionMode ? "Select Branch" : "Map")
                .edgesIgnoringSafeArea(.all)
            }
        }
}

