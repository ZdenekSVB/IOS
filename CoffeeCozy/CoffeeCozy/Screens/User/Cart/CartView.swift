//
//  CartView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation

struct CartView: View {
    @ObservedObject var viewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showMapSelection = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        VStack(spacing: 12) {
            Capsule().frame(width: 40, height: 5).foregroundColor(.gray.opacity(0.4)).padding(.top)
            
            Text("Shopping Cart").font(.title2).bold()
            
            
            ForEach(viewModel.items) { cartItem in
                HStack {
                    VStack(alignment: .leading) {
                        Text(cartItem.item.name)
                        Text("\(cartItem.quantity)x").font(.subheadline).foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(cartItem.item.price * Double(cartItem.quantity), specifier: "%.0f")$")
                    
                    HStack(spacing: 8) {
                        Button(action: { viewModel.increment(cartItem) }) {
                            Text("+")
                                .frame(width: 30, height: 30)
                                .background(Color.brown.opacity(0.6))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        Button(action: { viewModel.decrement(cartItem) }) {
                            Text("-")
                                .frame(width: 30, height: 30)
                                .background(Color.brown.opacity(0.9))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            
            HStack {
                Menu {
                    ForEach(viewModel.branches) { branch in
                        Button(branch.name) {
                            viewModel.selectedBranch = branch
                        }
                    }
                    
                    Divider()
                    
                    Button("Select on map") {
                        showMapSelection = true
                    }
                } label: {
                    Label(
                        viewModel.selectedBranch?.name ?? "Choose branch",
                        systemImage: "chevron.down"
                    )
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .padding(.horizontal)
            .sheet(isPresented: $showMapSelection) {
                MapView(
                    viewModel: MapViewModel(),
                    selectionMode: true,
                    onSelect: { selectedCafe in
                        viewModel.selectedBranch = selectedCafe
                        showMapSelection = false
                    }
                )
            }
            
            
            VStack {
                Text("You have \(viewModel.userPoints) point(s)")
                    .font(.subheadline)
                    .padding(.top)
                
                let remainingRedeemable = max(0, viewModel.redeemableCount - viewModel.redeemedFreeCoffees)
                
                Text("You can redeem up to \(viewModel.redeemableCount) free coffee(s)")
                Text("Redeemed: \(viewModel.redeemedFreeCoffees)")
                
                ForEach(viewModel.items) { cartItem in
                    let redeemedCount = viewModel.freeCoffeeRedemptions[cartItem.id] ?? 0
                    let maxRedeemForItem = cartItem.quantity - redeemedCount
                    
                    HStack {
                        Text("\(cartItem.item.name) (\(cartItem.quantity)x)")
                        
                        Spacer()
                        
                        Text("Redeemed: \(redeemedCount)")
                            .foregroundColor(Color("Paleta3"))
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                viewModel.removeRedeemedFreeCoffee(for: cartItem)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(redeemedCount > 0 ? .red : .gray)
                                    .font(.title2)
                            }
                            .disabled(redeemedCount == 0)
                            
                            Button(action: {
                                if remainingRedeemable > 0 && maxRedeemForItem > 0 {
                                    viewModel.redeemFreeCoffee(for: cartItem)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(maxRedeemForItem > 0 && remainingRedeemable > 0 ? .green : .gray)
                                    .font(.title2)
                            }
                            .disabled(maxRedeemForItem == 0 || remainingRedeemable == 0)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            
            
            
            
            Button(action: {
                guard !viewModel.items.isEmpty else {
                    alertTitle = "Missing Items"
                    alertMessage = "Please add at least one item to your cart."
                    showAlert = true
                    return
                }
                
                guard viewModel.selectedBranch != nil else {
                    alertTitle = "Branch Required"
                    alertMessage = "Please select a branch before placing your order."
                    showAlert = true
                    return
                }
                
                viewModel.submitOrder { result in
                    switch result {
                    case .success:
                        print("Objednávka úspěšně odeslána.")
                        
                        alertTitle = "Order Sent"
                        alertMessage = "Your order was successfully placed."
                        showAlert = true
                        
                    case .failure(let error):
                        print("Chyba při odesílání objednávky: \(error.localizedDescription)")
                        alertTitle = "Error"
                        alertMessage = "Order failed: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }) {
                Text("Buy for \(viewModel.totalPrice, specifier: "%.0f") $")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .bold()
            }
            .padding(.horizontal)
            
            
            Spacer()
        }
        .padding(.top)
        .background(Color("Paleta1").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Order Sent" {
                        dismiss()
                    }
                }
            )
        }
    }
}

