//
//  ComparisonView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct ComparisonView: View {
    let newItem: AItem, currentItem: AItem?
    let onEquip: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Porovnání Vybavení").font(.headline).padding(.top)
            HStack(alignment: .top) {
                VStack { Text("NOVÝ").font(.caption).bold().foregroundColor(.green); ItemDetailCard(item: newItem) }
                Image(systemName: "arrow.right").padding(.top, 40)
                VStack { Text("NASAZENO").font(.caption).bold().foregroundColor(.gray)
                    if let current = currentItem { ItemDetailCard(item: current) }
                    else { Text("Prázdné").frame(width: 120, height: 120).background(Color.gray.opacity(0.1)).cornerRadius(12) }
                }
            }
            Spacer()
            Button(action: { onEquip(); dismiss() }) {
                Text("NASADIT").bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(12)
            }.padding()
        }.presentationDetents([.medium])
    }
}
