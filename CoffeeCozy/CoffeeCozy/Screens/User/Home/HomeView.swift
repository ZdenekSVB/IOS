//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var homeVM = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to CoffeeCozy")
                    .font(.title)
                    .padding()
                
                NavigationLink("Go to Map") {
                    MapView(viewModel: MapViewModel())
                }
                .font(.title2)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                TextField("Enter total price (USD)", text: $homeVM.totalPriceText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding(.horizontal)

                Text("Current Reward Points: \(homeVM.rewardPoints)")
                    .font(.headline)

                Button("Calculate and Save Points") {
                    homeVM.savePoints()
                }
                .disabled(homeVM.isLoading)

                Button("Claim Free Coffee (-10 points)") {
                    homeVM.claimFreeCoffee()
                }
                .disabled(homeVM.rewardPoints < 10 || homeVM.isLoading)

                if !homeVM.message.isEmpty {
                    Text(homeVM.message)
                        .foregroundColor(.green)
                        .padding()
                }
                
                Spacer()
            }
            .toolbar {
                Toolbar()
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileIconButton(imageUrl: homeVM.profileImageUrl)
                }
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .onAppear {
                homeVM.fetchRewardPoints()
            }
        }
    }
}
