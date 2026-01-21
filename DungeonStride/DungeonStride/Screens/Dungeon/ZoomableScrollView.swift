//
//  ZoomableScrollView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 21.01.2026.
//

import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    var contentSize: CGSize
    var content: Content
    
    init(contentSize: CGSize, @ViewBuilder content: () -> Content) {
        self.contentSize = contentSize
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 0.1
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .black
        scrollView.contentInsetAdjustmentBehavior = .never // Ignoruje safe area
        
        // Vytvoření kontejneru pro SwiftUI
        let hostedView = context.coordinator.hostingController.view!
        hostedView.backgroundColor = .clear
        // Nastavíme frame natvrdo hned na začátku
        hostedView.frame = CGRect(origin: .zero, size: contentSize)
        hostedView.autoresizingMask = [] // Vypneme automatické změny velikosti
        
        scrollView.addSubview(hostedView)
        scrollView.contentSize = contentSize
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // 1. Aktualizujeme data v SwiftUI view (např. pohyb hráče)
        context.coordinator.hostingController.rootView = content
        
        // 2. Ujistíme se, že velikost sedí (pro případ změny mapy)
        let hostedView = context.coordinator.hostingController.view!
        if hostedView.frame.size != contentSize {
            hostedView.frame = CGRect(origin: .zero, size: contentSize)
            uiView.contentSize = contentSize
        }
        
        // 3. INICIALIZACE (Pouze jednou!)
        if !context.coordinator.isInitialSetup {
            // Čekáme, až bude mít scrollView rozměr na obrazovce (layout pass)
            DispatchQueue.main.async {
                if uiView.bounds.width > 0 {
                    context.coordinator.isInitialSetup = true
                    self.centerMap(uiView)
                }
            }
        }
    }
    
    // Logika pro vycentrování a nastavení zoomu
    private func centerMap(_ scrollView: UIScrollView) {
        let boundsSize = scrollView.bounds.size
        
        // 1. Spočítat Zoom tak, aby se mapa vešla (nebo byla rozumně vidět)
        let scaleWidth = boundsSize.width / contentSize.width
        let scaleHeight = boundsSize.height / contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        // Nastavíme zoom (např. 1.5x minimálního, aby to nebylo moc mrňavé)
        let targetScale = minScale * 1.5
        
        scrollView.minimumZoomScale = minScale * 0.8 // Povolíme oddálit víc než je fit
        scrollView.zoomScale = targetScale
        
        // 2. Vycentrovat na střed mapy
        // Střed obsahu při aktuálním zoomu
        let contentCenterX = (contentSize.width * targetScale) / 2
        let contentCenterY = (contentSize.height * targetScale) / 2
        
        // Odečteme polovinu velikosti obrazovky
        let offsetX = contentCenterX - (boundsSize.width / 2)
        let offsetY = contentCenterY - (boundsSize.height / 2)
        
        // Ošetření hranic (aby to nešlo do mínusu)
        let maxOffsetX = max(0, (contentSize.width * targetScale) - boundsSize.width)
        let maxOffsetY = max(0, (contentSize.height * targetScale) - boundsSize.height)
        
        let finalX = max(0, min(offsetX, maxOffsetX))
        let finalY = max(0, min(offsetY, maxOffsetY))
        
        scrollView.contentOffset = CGPoint(x: finalX, y: finalY)
        
        print("📍 MAPA NASTAVENA: Scale: \(targetScale), Offset: \(finalX), \(finalY)")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(hostingController: UIHostingController(rootView: content))
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var isInitialSetup = false
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
