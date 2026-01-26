//
//  InputStyle.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct InputStyle: ViewModifier {
    var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(12)
            .foregroundColor(themeManager.primaryTextColor)
    }
}

