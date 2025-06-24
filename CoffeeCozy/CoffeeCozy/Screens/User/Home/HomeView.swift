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
            VStack{
                Text("You currently have \(viewModel.rewardPoints) points, yey!")
                    .background(Color("Paleta3"))
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(12)
                
                Spacer()
                
                if let order = viewModel.latestOrder {
                    LatestOrderCard(order: order)
                } else {
                    Text("You have no orders")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                

                NavigationLink("Find us") {
                    MapView(viewModel: MapViewModel())
                }
                .font(.title2)
                .padding()
                .background(Color("Paleta3"))
                .foregroundColor(.white)
                .cornerRadius(12)
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
        /*.padding(.top)
        .background(Color("Paleta1").ignoresSafeArea())*/
    }
}
