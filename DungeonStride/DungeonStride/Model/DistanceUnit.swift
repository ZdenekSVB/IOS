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
    
    var distanceUnit: String {
        switch self {
        case .metric: return "km"
        case .imperial: return "mi"
        case .nautical: return "nmi"
        case .astronomical: return "AU"
        }
    }
    
    // Přijímá metry a konvertuje na cílové jednotky
    func convertFromMeters(_ meters: Int) -> Double {
        let kilometers = Double(meters) / 1000.0
        
        switch self {
        case .metric: 
            return kilometers
        case .imperial: 
            return kilometers * 0.621371 // km to miles
        case .nautical: 
            return kilometers * 0.539957 // km to nautical miles
        case .astronomical: 
            return kilometers * 6.6846e-9 // km to AU
        }
    }
    
    // Přijímá metry
    func formatDistance(_ meters: Int) -> String {
        let converted = convertFromMeters(meters)
        
        switch self {
        case .metric, .imperial, .nautical:
            if converted < 1 {
                return String(format: "%.1f %@", converted, distanceUnit)
            } else {
                return String(format: "%.0f %@", converted, distanceUnit)
            }
        case .astronomical:
            return String(format: "%.2e %@", converted, distanceUnit)
        }
    }
    
    // Formátování pro menší vzdálenosti (např. v questech)
    func formatSmallDistance(_ meters: Int) -> String {
        switch self {
        case .metric:
            if meters < 1000 {
                return "\(meters) m"
            } else {
                return String(format: "%.1f km", Double(meters) / 1000.0)
            }
        case .imperial:
            let miles = Double(meters) * 0.000621371
            if miles < 1 {
                let yards = Double(meters) * 1.09361
                return String(format: "%.0f yd", yards)
            } else {
                return String(format: "%.1f mi", miles)
            }
        case .nautical:
            let nauticalMiles = Double(meters) * 0.000539957
            return String(format: "%.1f nmi", nauticalMiles)
        case .astronomical:
            let au = Double(meters) * 6.6846e-12
            return String(format: "%.2e AU", au)
        }
    }
}
