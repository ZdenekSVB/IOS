//
//  OrderHistoryCard.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 20.06.2025.
//

import Foundation
import SwiftUI

struct OrderHistoryCard: View {
    
    let item: OrderItemA
    
    var statusColor: Color {
            switch item.status.lowercased() {
            case "finished": return .green
            case "pending": return .orange
            default: return .gray
            }
        }
        
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order #\(item.id.uuidString.prefix(6))")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()

                Spacer()

                Text(item.status.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(statusColor)
                    .clipShape(Capsule())
            }
            .padding()
            .background(Color.brown)
            .clipShape(.capsule(style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.createdAt.formatted(date: .numeric, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.black)

                Divider()

                ForEach(item.items) { product in
                    HStack {
                        Text("\(product.quantity)x \(product.name)")
                        Spacer()
                        Text("\(product.price, specifier: "%.0f")$")
                    }
                }

                Divider()

                HStack {
                    Text("Total:")
                        .bold()
                    Spacer()
                    Text("\(item.totalPrice, specifier: "%.0f")$")
                        .bold()
                }
            }
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}
