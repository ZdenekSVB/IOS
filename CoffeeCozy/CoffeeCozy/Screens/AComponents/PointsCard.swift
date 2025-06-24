//
//  PointsCard.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 24.06.2025.
//

import SwiftUI
import Foundation

struct PointsCard : View {
    let points: Int64
    
    
    var body: some View{
        NavigationStack {
            Text("You have \(points), yey!")
        }
    }
}
