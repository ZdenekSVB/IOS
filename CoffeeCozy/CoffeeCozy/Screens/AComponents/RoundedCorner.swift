//
//  RoundedCorner.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 18.06.2025.
//
import SwiftUI
import UIKit

struct RoundedCorner: Shape {
    var radius: CGFloat = 10
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
