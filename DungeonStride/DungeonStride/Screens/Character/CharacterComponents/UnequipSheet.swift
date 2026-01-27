//
//  UnequipSheet.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct UnequipSheet: View {
    let item: AItem
    let onUnequip: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ItemIconView(item: item, size: 100) // Používáme naši novou komponentu
                    
                    Text(item.name)
                        .font(.title3).bold()
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.lightImpact()
                    SoundManager.shared.playSystemClick()
                    onUnequip()
                    dismiss()
                }) {
                    Label("Unequip", systemImage: "arrow.down.doc.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .presentationDetents([.medium])
    }
}
