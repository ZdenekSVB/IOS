//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//
import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Orders")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
            .toolbar {
                UserToolbar()
            }
            .navigationTitle("Orders")
            .background(Color("paleta1").ignoresSafeArea())
        }
    }
}
