//
//  AOrderDetailView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//


// AOrderDetailView.swift
// CoffeeCozy

import SwiftUI

struct AOrderDetailView: View {
    let order: OrderRecord

    var body: some View {
        VStack(spacing: 16) {
            Text("User: \(order.userName)")
                .font(.title2).bold()

            Text("Date: \(order.date, style: .date) \(order.date, style: .time)")
                .font(.body)

            Text(String(format: "Total: %.2f Kč", order.total))
                .font(.title3)

            Spacer()
        }
        .padding()
        .background(Color("Paleta1").ignoresSafeArea())
        .navigationTitle("Order Details")
    }
}
