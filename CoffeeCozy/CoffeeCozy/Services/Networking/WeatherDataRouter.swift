//
//  WeatherDataRouter.swift
//  CityGuide
//
//  Created by Tomas Cejka on 23.04.2025.
//

import Foundation

enum WeatherDataRouter: Endpoint {
    
    case dailyMaxTemperature(long: Double, lat: Double)
    case hourlyTemperature(long: Double, lat: Double)

    var path: String {
        "v1/forecast"
    }

    var urlParameters: [String : Any]? {
        switch self {
        case let .dailyMaxTemperature(long, lat):
            ["longitude": long, "latitude": lat, "daily": "temperature_2m_max"]
        case let .hourlyTemperature(long, lat):
            ["longitude": long, "latitude": lat, "hourly": "temperature_2m"]
        }
    }
}
