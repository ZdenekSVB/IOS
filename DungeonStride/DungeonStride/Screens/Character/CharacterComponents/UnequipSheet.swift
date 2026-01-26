//
//  UnequipSheet.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct UnequipSheet: View {
    let item: AItem, onUnequip: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(item.name).font(.title3).bold().padding(.top)
            ItemDetailCard(item: item)
            Text(item.description).font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            Spacer()
            Button(action: { onUnequip(); dismiss() }) {
                Label("Sundat (Unequip)", systemImage: "arrow.down.doc.fill").bold().frame(maxWidth: .infinity).padding().background(Color.red.opacity(0.8)).foregroundColor(.white).cornerRadius(12)
            }.padding()
        }.presentationDetents([.medium])
    }
}
