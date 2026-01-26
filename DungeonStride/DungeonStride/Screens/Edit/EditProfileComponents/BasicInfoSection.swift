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
            LabeledInput(label: "USERNAME", themeManager: themeManager) {
                TextField("Enter username", text: $username)
            }
            
            LabeledInput(label: "EMAIL (Cannot change)", themeManager: themeManager) {
                Text(email)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .opacity(0.8)
        }
    }
}
