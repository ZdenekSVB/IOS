//
// OrderCard.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI

struct OrderCard: View {
    let orderNumber: String
    let date: String
    let time: String
    let items: [OrderItem]
    let total: Double
    @Binding var status: OrderStatus
    var onStatusChange: (OrderStatus) -> Void

    @State private var showingStatusSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Order #\(orderNumber)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    showingStatusSheet = true
                } label: {
                    Text(status.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(status.color)
                        .clipShape(Capsule())
                }
                .actionSheet(isPresented: $showingStatusSheet) {
                    ActionSheet(
                        title: Text("Change Order Status"),
                        buttons: [
                            .default(Text("Pending")) {
                                updateStatus(.pending)
                            },
                            .default(Text("Finished")) {
                                updateStatus(.finished)
                            },
                            .default(Text("Cancelled")) {
                                updateStatus(.cancelled)
                            },
                            .cancel()
                        ])
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(red: 0.51, green: 0.35, blue: 0.22))

            VStack(alignment: .leading, spacing: 12) {
                Text("\(date) at \(time)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    ForEach(items, id: \.itemId) { item in
                        HStack {
                            Text("\(item.quantity)x \(item.name)")
                            Spacer()
                            Text("\(item.price, specifier: "%.0f")$")
                        }
                        .font(.body)
                    }
                }

                Divider().padding(.vertical, 4)

                HStack {
                    Text("Total:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(total, specifier: "%.0f")$")
                        .fontWeight(.medium)
                }
                .font(.body)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func updateStatus(_ newStatus: OrderStatus) {
        status = newStatus
        onStatusChange(newStatus)
    }
}


struct StatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(status.color)
            .clipShape(Capsule())
    }
}
