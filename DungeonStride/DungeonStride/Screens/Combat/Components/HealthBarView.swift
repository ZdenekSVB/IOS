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
        guard max > 0 else { return 0 }
        return Double(current) / Double(max)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                Capsule().frame(width: 100, height: 10).foregroundColor(
                    .gray.opacity(0.5)
                )
                Capsule().frame(width: 100 * CGFloat(percent), height: 10)
                    .foregroundColor(color)
            }
            Text("\(current)/\(max)")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
