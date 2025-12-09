//
//  DungeonView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


import SwiftUI

struct DungeonMapView: View {
    @EnvironmentObject var themeManager: ThemeManager // ← PŘIDÁNO
    @StateObject private var viewModel = DungeonMapViewModel()
    @State private var isSheetPresented = false
    
    var body: some View {
        NavigationView {
            // Použijeme vnořenou struct (UIKit Bridge) pro zobrazení mapy
            UIKitMapWrapper(viewModel: viewModel, showBottomSheet: $isSheetPresented)
                .navigationTitle("Moje Mapa (Minimal)")
                .sheet(isPresented: $isSheetPresented) {
                    bottomSheetView
                        .presentationDetents([.medium, .large])
                        .presentationCornerRadius(20)
                        .presentationDragIndicator(.visible)
                }
        }
    }
    
    private var bottomSheetView: some View {
            VStack {
                Spacer()
                Text(viewModel.bottomSheetText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Text("Pozice: (\(Int(viewModel.characterPosition.x)), \(Int(viewModel.characterPosition.y)))")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    
    private struct UIKitMapWrapper: UIViewRepresentable {
            
            var viewModel: DungeonMapViewModel
            @Binding var showBottomSheet: Bool
            
            func makeUIView(context: Context) -> UIScrollView {
                let scrollView = UIScrollView()
                scrollView.delegate = context.coordinator
                scrollView.minimumZoomScale = 0.1
                scrollView.maximumZoomScale = 4.0
                scrollView.contentSize = viewModel.mapSize
                
                // UIImageView
                guard let image = UIImage(named: viewModel.mapImageName) else { return scrollView }
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(origin: .zero, size: viewModel.mapSize)
                imageView.isUserInteractionEnabled = true
                scrollView.addSubview(imageView)
                
                // Tlačítko (Postavička)
                let characterButton = UIButton(type: .custom)
                characterButton.backgroundColor = .red
                characterButton.layer.cornerRadius = viewModel.characterSize / 2
                characterButton.layer.borderColor = UIColor.white.cgColor
                characterButton.layer.borderWidth = 2
                characterButton.frame = viewModel.characterFrame
                
                // Cíl akce směřuje na Coordinator
                characterButton.addTarget(context.coordinator, action: #selector(Coordinator.characterTapped), for: .touchUpInside)
                
                imageView.addSubview(characterButton)
                
                // Počáteční zoom
                DispatchQueue.main.async {
                    scrollView.zoomScale = viewModel.initialZoomScale
                }
                
                return scrollView
            }
            
            func updateUIView(_ uiView: UIScrollView, context: Context) {
                // Při aktualizaci View není třeba nic dělat
            }
            
            func makeCoordinator() -> Coordinator {
                Coordinator(self)
            }
            
            // MARK: - Coordinator (Delegate)
            
            class Coordinator: NSObject, UIScrollViewDelegate {
                var parent: UIKitMapWrapper
                
                init(_ parent: UIKitMapWrapper) {
                    self.parent = parent
                }
                
                func viewForZooming(in scrollView: UIScrollView) -> UIView? {
                    return scrollView.subviews.first
                }
                
                func scrollViewDidZoom(_ scrollView: UIScrollView) {
                    // Centrování obsahu
                    let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
                    let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
                    scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
                }
                
                @objc func characterTapped() {
                    // 1. Logika do ViewModelu
                    parent.viewModel.handleCharacterTap()
                    
                    // 2. Nastavení stavu pro zobrazení sheetu
                    parent.showBottomSheet = true
                }
            }
        }
}
