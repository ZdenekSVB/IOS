//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("Paleta1").ignoresSafeArea()
                
                VStack{
                    Text("You currently have \(viewModel.rewardPoints) points, yey!")
                        .background(Color("Paleta3"))
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    if let order = viewModel.latestOrder {
                        OrderCard(
                            orderNumber: order.id ?? "N/A",
                            date: viewModel.formattedDate(order.createdAt),
                            time: viewModel.formattedTime(order.createdAt),
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
                        //LatestOrderCard(order: order)
                    } else {
                        Text("You have no orders")
                            .foregroundColor(.gray)
                    }
                    
                    
                    NavigationLink("Find us") {
                        MapView(viewModel: MapViewModel())
                    }
                    .font(.title2)
                    .padding()
                    .background(Color("Paleta3"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color("Paleta1").ignoresSafeArea())
            .toolbar {
                Toolbar()
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileIconButton(imageUrl: viewModel.profileImageUrl)
                }
            }
            .onAppear {
                viewModel.fetchRewardPoints()
                viewModel.fetchLatestOrder()
            }
            
        }
    }
}
