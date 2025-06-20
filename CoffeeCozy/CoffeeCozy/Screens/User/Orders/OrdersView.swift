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
                    if viewModel.orders.isEmpty {
                        Spacer()
                        Text("No orders yet.")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.orders) { order in
                                    OrderHistoryCard(item: order)
                                }
                            }
                            .padding(.top)
                        }
                    }
                }
                .navigationTitle("Orders")
                .background(Color("paleta1").ignoresSafeArea())
                .toolbar {
                    UserToolbar()
                }
                .onAppear{
                    viewModel.fetchOrders()
                }
            }
        }
}
