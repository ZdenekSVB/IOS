//
//  HealthBarView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 26.01.2026.
//

import SwiftUI

struct HealthBarView: View {
    let current: Int
    let max: Int
    let color: Color
    
    var percent: Double {
        return Double(current) / Double(max)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Pozadí
            Capsule().frame(height: 12).foregroundColor(Color.gray.opacity(0.3))
            // Popředí (Bar)
            Capsule().frame(width: CGFloat(percent) * 300, height: 12) // 300 je šířka baru, uprav dle potřeby
                .foregroundColor(color)
                .animation(.linear, value: current)
            
            // Text HP
            Text("\(current) / \(max)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 8)
        }
        .frame(height: 12)
    }
}
