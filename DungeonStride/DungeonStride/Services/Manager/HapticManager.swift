//
//  HapticManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 22.01.2026.
//

import UIKit

class HapticManager {
    
    // Singleton instance pro snadný přístup odkudkoliv
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Jemné ťuknutí (např. kliknutí na tlačítko, přepínač)
    /// - Parameter enabled: Pokud je false, vibrace se neprovede. Default je true.
    func lightImpact(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Střední ťuknutí (např. výběr položky, tab bar)
    /// - Parameter enabled: Pokud je false, vibrace se neprovede. Default je true.
    func mediumImpact(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Silné ťuknutí (např. kolize, náraz)
    /// - Parameter enabled: Pokud je false, vibrace se neprovede. Default je true.
    func heavyImpact(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Úspěch (např. splnění questu, uložení nastavení, level up)
    /// - Parameter enabled: Pokud je false, vibrace se neprovede. Default je true.
    func success(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Varování (např. mazání účtu, kritická akce)
    /// - Parameter enabled: Pokud je false, vibrace se neprovede. Default je true.
    func warning(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Chyba (např. špatné heslo, chyba sítě)
    /// - Parameter enabled: Pokud je false, vibrace se neprovede. Default je true.
    func error(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}
