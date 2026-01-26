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
            Text("CHANGE PASSWORD (OPTIONAL)") // Key pro lokalizaci
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            VStack(spacing: 12) {
                SecureField("Current Password", text: $oldPassword)
                    .modifier(InputStyle(themeManager: themeManager))
                
                SecureField("New Password", text: $newPassword)
                    .modifier(InputStyle(themeManager: themeManager))
                
                SecureField("Confirm New Password", text: $confirmPassword)
                    .modifier(InputStyle(themeManager: themeManager))
            }
        }
    }
}
