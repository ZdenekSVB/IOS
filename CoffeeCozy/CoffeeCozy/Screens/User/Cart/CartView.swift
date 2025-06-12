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

    var body: some View {
        VStack(spacing: 12) {
            Capsule().frame(width: 40, height: 5).foregroundColor(.gray.opacity(0.4)).padding(.top)

            Text("Shopping Cart").font(.title2).bold()

            
            ForEach(viewModel.items) { cartItem in
                HStack {
                    // Ikonka
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.brown)

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
                Button("Pick-up") {
                    viewModel.isDelivery = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(!viewModel.isDelivery ? Color.white : Color.clear)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                Button("Deliver") {
                    viewModel.isDelivery = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isDelivery ? Color.white : Color.clear)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            }
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)

            
            HStack {
                Text("Choose branch")
                Spacer()
                Text("Label ⌄")
            }
            .padding(.horizontal)

           
            HStack {
                Text("Choose payment method")
                Spacer()
                Text("Label ⌄")
            }
            .padding(.horizontal)

            
            TextField("Note", text: $viewModel.note)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal)

            
            Button(action: {
                
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
    }
}

