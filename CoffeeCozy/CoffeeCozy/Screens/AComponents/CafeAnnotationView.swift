//
//  CafeAnnotationView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 23.06.2025.
//

import SwiftUI

struct CafeAnnotationView: View {
    let cafe: Cafe
    let selectionMode: Bool
    let onSelect: ((Cafe) -> Void)?

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.5))
                .stroke(.white.opacity(0.8), lineWidth: 2.0)
                .frame(width: 36)
            VStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                Text(cafe.name)
                    .font(.caption2)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(5)
            }
        }
        .onTapGesture {
            if selectionMode {
                onSelect?(cafe)
            }
        }
    }
}
