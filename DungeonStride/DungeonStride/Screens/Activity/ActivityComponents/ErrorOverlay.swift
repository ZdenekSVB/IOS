//
//  ErrorOverlay.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI
import MapKit
import Charts
import CoreLocation

// MARK: - Overlay
struct ErrorOverlay: View {
    let message: String
    var body: some View {
        VStack {
            Spacer()
            Text("⚠️ \(message)")
                .padding()
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 50)
        }
        .transition(.move(edge: .bottom))
        .zIndex(2)
    }
}
