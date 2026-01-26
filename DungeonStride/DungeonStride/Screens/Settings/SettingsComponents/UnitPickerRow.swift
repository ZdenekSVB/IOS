//
//  UnitPickerRow.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct UnitPickerRow: View {
    @Binding var selectedUnit: DistanceUnit
    var hapticsEnabled: Bool
    @ObservedObject var themeManager: ThemeManager
    let onUpdate: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundColor(themeManager.accentColor)
                .frame(width: 30)
            Text("Units") // Lokalizace
                .foregroundColor(themeManager.primaryTextColor)
            Spacer()
            Picker("", selection: $selectedUnit) {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedUnit) { _, _ in
                onUpdate()
                HapticManager.shared.mediumImpact(enabled: hapticsEnabled)
                // Picker (menu style) má systémový zvuk, ale můžeme přidat kliknutí pro jistotu
                // SoundManager.shared.playSystemClick()
            }
        }
        .padding()
        .background(themeManager.cardBackgroundColor)
    }
}
