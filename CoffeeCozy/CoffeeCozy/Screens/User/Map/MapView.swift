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
            self._viewModel = State(initialValue: viewModel)
            self.selectionMode = selectionMode
            self.onSelect = onSelect
        }
    
    var body: some View {
            NavigationStack {
                Map(position: $viewModel.state.mapCameraPosition, interactionModes: [.pan, .zoom]) {
                    ForEach(viewModel.cafes) { cafe in
                        Annotation("", coordinate: cafe.coordinates) {
                            VStack(spacing: 5) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                Text(cafe.name)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .onTapGesture {
                                if selectionMode {
                                    selectedCafe = cafe
                                }
                            }
                        }
                    }
                }
                .navigationTitle(selectionMode ? "Select Branch" : "Map")
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
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
}
