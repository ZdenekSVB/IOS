//
//  InfoRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.system(.body, design: .monospaced))
        }
        .font(.caption)
    }
}
