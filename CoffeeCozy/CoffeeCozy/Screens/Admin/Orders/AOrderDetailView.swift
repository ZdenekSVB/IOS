//
// AOrderDetailView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI

struct AOrderDetailView: View {
    let order: OrderRecord
    @ObservedObject var viewModel: AOrdersViewModel
    @State private var status: OrderStatus

    init(order: OrderRecord, viewModel: AOrdersViewModel) {
        self.order = order
        self.viewModel = viewModel
        _status = State(initialValue: OrderStatus(rawValue: order.status) ?? .unknown)
    }

    var body: some View {
        ZStack {
            Color("Paleta1").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                OrderCard(
                    orderNumber: order.id ?? "Unknown",
                    date: DateFormatter.localizedString(from: order.createdAt, dateStyle: .short, timeStyle: .none),
                    time: DateFormatter.localizedString(from: order.createdAt, dateStyle: .none, timeStyle: .short),
                    items: order.items,
                    total: order.totalPrice,
                    status: $status,
                    onStatusChange: { newStatus in
                        viewModel.updateOrderStatus(orderId: order.id ?? "", newStatus: newStatus.rawValue)
                    },
                    isAdmin: true
                )

            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
