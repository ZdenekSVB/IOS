//
//  DistanceUnit.swift
//  DungeonStride
//

import Foundation

enum DistanceUnit: String, Codable, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"
    case nautical = "nautical"
    case astronomical = "astronomical"
    
    var displayName: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        case .nautical: return "Nautical"
        case .astronomical: return "Astronomical"
        }
    }
    
    var symbol: String {
        switch self {
        case .metric: return "km"
        case .imperial: return "mi"
        case .nautical: return "nmi"
        case .astronomical: return "AU"
        }
    }
    
    var speedSymbol: String {
        switch self {
        case .metric: return "km/h"
        case .imperial: return "mph"
        case .nautical: return "kn"
        case .astronomical: return "AU/h"
        }
    }
    
    // MARK: - Conversions
    
    /// Převede metry na zvolenou jednotku vzdálenosti
    func convertFromMeters(_ meters: Int) -> Double {
        let kilometers = Double(meters) / 1000.0
        
        switch self {
        case .metric:
            return kilometers
        case .imperial:
            return kilometers * 0.621371
        case .nautical:
            return kilometers * 0.539957
        case .astronomical:
            return kilometers * 6.6846e-9
        }
    }
    
    /// Převede rychlost z m/s na zvolenou jednotku
    func convertSpeed(fromMetersPerSecond ms: Double) -> Double {
        switch self {
        case .metric:
            return ms * 3.6          // m/s -> km/h
        case .imperial:
            return ms * 2.23694      // m/s -> mph
        case .nautical:
            return ms * 1.94384      // m/s -> knots
        case .astronomical:
            return ms * 0.0          // Nedává smysl, ale pro bezpečnost 0
        }
    }
    
    // MARK: - Formatting
    
    func formatDistance(_ meters: Int) -> String {
        let converted = convertFromMeters(meters)
        
        if self == .astronomical {
            return String(format: "%.2e %@", converted, symbol)
        } else {
            return String(format: "%.2f %@", converted, symbol)
        }
    }
    
    /// Formátuje rychlost (vstup je v m/s)
    func formatSpeed(metersPerSecond: Double) -> String {
        guard metersPerSecond >= 0 else { return "0.0 \(speedSymbol)" }
        let converted = convertSpeed(fromMetersPerSecond: metersPerSecond)
        return String(format: "%.1f %@", converted, speedSymbol)
    }
}
