//
//  MetricItem.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI
import MapKit
import Charts
import CoreLocation

struct MetricItem: View {
    let title: String
    let value: String
    let themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeManager.secondaryTextColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(themeManager.primaryTextColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
