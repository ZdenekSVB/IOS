//
//  Utils.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.06.2025.
//
import SwiftUI

extension Date {
    func endOfDay() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components) ?? self
    }
}
