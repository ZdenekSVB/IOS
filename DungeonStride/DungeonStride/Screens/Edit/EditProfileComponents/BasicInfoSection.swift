//
//  BasicInfoSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct BasicInfoSection: View {
    @Binding var username: String
    let email: String
    var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LabeledInput(label: "UŽIVATELSKÉ JMÉNO", themeManager: themeManager) {
                TextField("Zadejte jméno", text: $username)
            }
            
            LabeledInput(label: "EMAIL (Nelze změnit)", themeManager: themeManager) {
                Text(email)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .opacity(0.8) // Vizuální indikace, že je to disabled
        }
    }
}
