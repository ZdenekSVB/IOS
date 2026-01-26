//
//  ActionSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct ActionSection: View {
    let errorMessage: String?
    let isLoading: Bool
    let accentColor: Color
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: onSave) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Changes") // Lokalizace
                        .bold()
                }
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: accentColor))
            .padding(.horizontal)
            .disabled(isLoading)
        }
    }
}
