//
//  PasswordSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI


struct PasswordSection: View {
    @Binding var oldPassword: String
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ZMĚNA HESLA (VOLITELNÉ)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            VStack(spacing: 12) {
                SecureField("Stávající heslo (pro potvrzení)", text: $oldPassword)
                    .modifier(InputStyle(themeManager: themeManager))
                
                SecureField("Nové heslo", text: $newPassword)
                    .modifier(InputStyle(themeManager: themeManager))
                
                SecureField("Potvrzení nového hesla", text: $confirmPassword)
                    .modifier(InputStyle(themeManager: themeManager))
            }
        }
    }
}
