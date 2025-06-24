//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//
import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = OrdersViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                DateFilter(from: $viewModel.dateFrom, to: $viewModel.dateTo) {
                    viewModel.fetchOrders()
                }
                if viewModel.orders.isEmpty {
                    Spacer()
                    Text("No orders found.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    OrdersList(orders: $viewModel.orders)
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .toolbar {
                Toolbar()
            }
            .onAppear {
                viewModel.fetchOrders()
            }
        }
    }
}


struct OrdersList: View {
    @Binding var orders: [OrderRecord]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach($orders) { $order in
                    OrdersRow(order: $order)
                }
            }
            .padding(.top)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
}

struct OrdersRow: View {
    @Binding var order: OrderRecord

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        OrderCard(
            orderNumber: order.id ?? "N/A",
            date: formattedDate(order.createdAt),
            time: formattedTime(order.createdAt),
            items: order.items,
            total: order.totalPrice,
            status: Binding(
                get: {
                    OrderStatus(rawValue: order.status) ?? .unknown
                },
                set: { _ in }
            ),
            onStatusChange: { _ in },
            isAdmin: false
        )
    }
}
