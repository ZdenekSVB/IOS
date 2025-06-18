//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import SwiftUI
import ImageIO

struct SortimentView: View {
    @StateObject private var viewModel = SortimentViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showCart = false
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.items) { item in
                            SortimentTile(
                                item: item,
                                isAdmin: false,
                                onEdit: {},
                                onAddToCart: {
                                    cartViewModel.add(item: item)
                                },
                                onTap: {}
                            )
                        }
                    }
                    .padding()
                }

                Button(action: { showCart = true }) {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("Košík")
                        Spacer()
                        Text("\(cartViewModel.totalPrice, specifier: "%.0f") Kč")
                    }
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .bold()
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .toolbar {
                UserToolbar()
            }
            .navigationTitle("Sortiment")
            .background(Color("paleta1").ignoresSafeArea())
            .sheet(isPresented: $showCart) {
                CartView(viewModel: cartViewModel)
            }
        }
    }
}
