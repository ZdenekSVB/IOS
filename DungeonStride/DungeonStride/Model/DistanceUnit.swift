//
//  DistanceUnit.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 05.11.2025.
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
    
    var paceLabel: String {
        switch self {
        case .metric: return "min/km"
        case .imperial: return "min/mi"
        case .nautical: return "min/nmi"
        case .astronomical: return "min/AU"
        }
    }
    
    // MARK: - Conversions
    
    /// Převede metry na zvolenou jednotku
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
    
    /// Převede tempo z min/km na tempo ve zvolené jednotce (pro grafy)
    func convertPace(fromMinPerKm val: Double) -> Double {
        switch self {
        case .metric:
            return val
        case .imperial:
            return val * 1.60934 // 1 mile = 1.609 km, takže trvá 1.6x déle urazit míli
        case .nautical:
            return val * 1.852   // 1 nmi = 1.852 km
        case .astronomical:
            return val * 149_597_870.7 // 1 AU = hodně km
        }
    }
    
    // MARK: - Formatting
    
    func formatDistance(_ meters: Int) -> String {
        let converted = convertFromMeters(meters)
        
        switch self {
        case .metric, .imperial, .nautical:
            if converted < 0.1 {
                 // Pro velmi malé vzdálenosti zobrazit menší jednotky, pokud dává smysl, nebo 0.00
                return String(format: "%.2f %@", converted, symbol)
            } else {
                return String(format: "%.2f %@", converted, symbol)
            }
        case .astronomical:
            return String(format: "%.2e %@", converted, symbol)
        }
    }
    
    func formatSmallDistance(_ meters: Int) -> String {
        // Specifické formátování pro malé cíle (questy)
        switch self {
        case .metric:
            return meters < 1000 ? "\(meters) m" : String(format: "%.1f km", Double(meters) / 1000.0)
        case .imperial:
            let miles = Double(meters) * 0.000621371
            return miles < 0.1 ? String(format: "%.0f yd", Double(meters) * 1.09361) : String(format: "%.2f mi", miles)
        default:
            return formatDistance(meters)
        }
    }
    
    /// Vypočítá a naformátuje tempo na základě času a vzdálenosti
    func formatPace(seconds: TimeInterval, distanceMeters: Double) -> String {
        guard distanceMeters > 10, seconds > 0 else {
            return "0'00\" / \(symbol)" // "0'00" / km" nebo "0'00" / mi"
        }
        
        let distInUnit = convertFromMeters(Int(distanceMeters))
        
        // Pace = Time (mins) / Distance (units)
        let totalMinutes = seconds / 60.0
        let paceValue = totalMinutes / distInUnit
        
        let minutes = Int(paceValue)
        let remainderSeconds = Int((paceValue - Double(minutes)) * 60)
        
        // Ošetření pro astronomické jednotky (kde by čísla byla obrovská)
        if self == .astronomical {
             return String(format: "%.2e min/AU", paceValue)
        }

        return String(format: "%d'%02d\" / %@", minutes, remainderSeconds, symbol)
    }
}
