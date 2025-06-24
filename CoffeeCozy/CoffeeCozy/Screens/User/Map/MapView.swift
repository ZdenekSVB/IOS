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
        //@State private var selectedCafe: Cafe?
    
    init(viewModel: MapViewModel, selectionMode: Bool = false, onSelect: ((Cafe) -> Void)? = nil) {
            self.viewModel = viewModel
            self.selectionMode = selectionMode
            self.onSelect = onSelect
        }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(
                    position: $viewModel.state.mapCameraPosition,
                    interactionModes: [.pan, .zoom]
                ) {
                    ForEach(viewModel.state.cafes) { cafe in
                        Annotation("", coordinate: cafe.coordinates) {
                            CafeAnnotationView(
                                cafe: cafe,
                                selectionMode: selectionMode,
                                onSelect: { selectedCafe in
                                    viewModel.selectCafe(selectedCafe)
                                }
                            )
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                if selectionMode, let selected = viewModel.state.selectedCafe {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected branch: \(selected.name)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top))
                }
            }
            .toolbar {
                if selectionMode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            if let selected = viewModel.state.selectedCafe {
                                onSelect?(selected)
                            }
                            dismiss()
                        }
                        .disabled(viewModel.state.selectedCafe == nil)
                    }
                }
            }
            .navigationTitle(selectionMode ? "Choose Branch" : "Where to find us")
            .onAppear {
                viewModel.fetchCafes()
            }
        }
    }
}
