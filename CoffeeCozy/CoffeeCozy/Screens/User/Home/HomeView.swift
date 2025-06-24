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
                    
                    VStack(spacing: 20) {
                        Text("You currently have \(viewModel.rewardPoints) points, yey!")
                            .frame(width: 350,height: 50)
                            .background(Color("Paleta3"))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                            
                            
                        
                        if let order = viewModel.latestOrder {
                            CurrentOrderCard(
                                order: order,
                                estimatedTime: 5,
                                onLocationTap: {
                                    print("Navigate to location")
                                }
                            )
                        } else {
                            NavigationLink("Find us") {
                                MapView(viewModel: MapViewModel())
                            }
                            .font(.title2)
                            .padding()
                            .background(Color("Paleta3"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        Spacer()
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
