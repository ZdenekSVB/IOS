//
//  TerrainToggleButton.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI
import MapKit
import Charts
import CoreLocation

// MARK: - Terrain Toggle Button
struct TerrainToggleButton: View {
    let isNautical: Bool
    let themeManager: ThemeManager
    
    // Přidáno pro kontrolu nastavení
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true
    
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Haptika & Zvuk
            HapticManager.shared.lightImpact(enabled: hapticsEnabled)
            if soundEnabled { SoundManager.shared.playSystemClick() }
            
            action()
        }) {
            Image(systemName: isNautical ? "sailboat.fill" : "figure.run")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 32)
                .background(isNautical ? Color.blue : Color.green)
                .cornerRadius(8)
        }
    }
}
