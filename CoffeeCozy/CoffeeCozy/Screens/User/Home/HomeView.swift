//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to CoffeeCozy")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
            .toolbar {
                UserToolbar()
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileView(viewModel: ProfileViewModel())
                    } label: {
                        Image(systemName: "person.fill")
                    }
                }
            }
            .navigationTitle("Home")
            .background(Color("Paleta1").ignoresSafeArea())
        }
    }
}
