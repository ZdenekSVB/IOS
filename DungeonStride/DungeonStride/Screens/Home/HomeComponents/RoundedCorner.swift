//
//  RoundedCorner.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI

// Pomocná struktura pro kulaté rohy jen na vybraných stranách
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
