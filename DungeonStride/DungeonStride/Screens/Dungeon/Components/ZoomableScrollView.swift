//
//  ZoomableScrollView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    private var contentSize: CGSize
    @Binding var centerOnPoint: CGPoint?
    
    init(contentSize: CGSize, centerOnPoint: Binding<CGPoint?>, @ViewBuilder content: () -> Content) {
        self.contentSize = contentSize
        self._centerOnPoint = centerOnPoint
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.2
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = CGRect(origin: .zero, size: contentSize)
        hostedView.backgroundColor = .clear
        
        scrollView.addSubview(hostedView)
        scrollView.contentSize = contentSize
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content
        
        if let centerPoint = centerOnPoint {
            let zoomScale = uiView.zoomScale
            let width = uiView.bounds.width / zoomScale
            let height = uiView.bounds.height / zoomScale
            
            let rect = CGRect(
                x: centerPoint.x - (width / 2),
                y: centerPoint.y - (height / 2),
                width: width,
                height: height
            )
            
            uiView.scrollRectToVisible(rect, animated: true)
            
            DispatchQueue.main.async {
                centerOnPoint = nil
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: content))
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
