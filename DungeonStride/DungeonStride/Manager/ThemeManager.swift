//
//  ThemeManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


//
//  ThemeManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    
    // Barvy pro dark/light mode
    var backgroundColor: Color {
        isDarkMode ? Color("Paleta3") : Color("Paleta6")
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color("Paleta5") : Color("Paleta4").opacity(0.1)
    }
    
    var primaryTextColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color("Paleta4") : Color("Paleta4").opacity(0.7)
    }
    
    var accentColor: Color {
        Color("Paleta2") // Tato zůstává stejná v obou módech
    }
    
    // Uložení nastavení do UserDefaults
    private let darkModeKey = "isDarkMode"
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: darkModeKey)
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: darkModeKey)
        
        // Nastav systémový appearance
        updateSystemAppearance()
    }
    
    private func updateSystemAppearance() {
        // Toto ovlivní status bar a další systémové prvky
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
}