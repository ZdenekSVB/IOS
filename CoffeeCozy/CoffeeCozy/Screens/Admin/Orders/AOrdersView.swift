// AOrdersView.swift
// CoffeeCozy

import SwiftUI
import Charts

struct AOrdersView: View {
    @StateObject private var viewModel = AOrdersViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.bottom, 8)

                // Orders over time chart
                Chart(viewModel.orderCounts) { oc in
                    LineMark(
                        x: .value("Date", oc.date, unit: .day),
                        y: .value("Orders", oc.count)
                    )
                    PointMark(
                        x: .value("Date", oc.date, unit: .day),
                        y: .value("Orders", oc.count)
                    )
                }
                .frame(height: 200)
                .padding(.horizontal)

                // List of orders
                List(viewModel.filteredOrders) { order in
                    NavigationLink {
                        AOrderDetailView(order: order)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(order.userName)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text(order.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Text(String(format: "%.2f Kč", order.total))
                                .font(.subheadline).bold()
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.white)
                    }
                }
                .listStyle(.plain)

                
            }
            .toolbar {
                AdminToolbar()
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear {
                viewModel.loadOrders()
            }
        }
    }
}
