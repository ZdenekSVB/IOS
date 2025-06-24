//
//  OrdersHomeCard.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 24.06.2025.
//
import SwiftUI
import Foundation

struct LatestOrderCard: View {
    let order: OrderRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Latest order")
                    .font(.headline)
                Spacer()
                Text(order.status.capitalized)
                    .font(.subheadline)
                    .foregroundColor(OrderStatus(rawValue: order.status)?.color ?? .gray)
            }
            
            ForEach(order.items) { item in
                HStack {
                    Text(item.name)
                    Text("x\(item.quantity)")
                    Spacer()
                    Text(String(format: "%.0f $", item.price))
                }
                .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                Text("Total:")
                    .bold()
                Spacer()
                Text(String(format: "%.0f $", order.totalPrice))
                    .bold()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

