//
// AOrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI
import Charts

struct AOrdersView: View {
    @StateObject private var viewModel = AOrdersViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.errorMessage.isEmpty {
                    VStack {
                        Text(viewModel.errorMessage)
                            .font(.headline)
                        Button("Try Again", action: viewModel.loadOrders)
                            .padding()
                    }
                } else if viewModel.orders.isEmpty {
                    Text("No orders found")
                } else {
                    SearchBar(text: $viewModel.searchText)
                    
                    GenericChartView(
                        dataPoints: viewModel.orderCounts,
                        lineColor: Color("Paleta3"),
                        pointColor: Color("Paleta4"),
                        annotationSuffix: "$ our revenue"
                    )
                    .padding()

                    List(viewModel.filteredOrders) { order in
                        NavigationLink(destination: AOrderDetailView(order: order, viewModel: viewModel)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(order.userName)
                                        .font(.headline)
                                    Text(order.createdAt, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(String(format: "%.2f $", order.totalPrice))
                                        .font(.subheadline)
                                        .bold()

                                    StatusBadge(status: OrderStatus(rawValue: order.status) ?? .unknown)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar { Toolbar() }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear(perform: viewModel.loadOrders)
        }
    }
}
