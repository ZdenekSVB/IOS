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
    @State private var showAlert = false
    @State private var alertMessage = "Hello"
    @State private var showMapSelection = false

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

            
            TextField("Note", text: $viewModel.note)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal)

            
            Button(action: {
                viewModel.submitOrder { result in
                       switch result {
                       case .success:
                           print("Objednávka úspěšně odeslána.")
                           showAlert = true
                       case .failure(let error):
                           print("Chyba při odesílání objednávky: \(error.localizedDescription)")
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
            .alert(alertMessage, isPresented: $showAlert){
                Button("OK"){
                    dismiss()
                }
            }


            Spacer()
        }
        .padding(.top)
        .background(Color("Paleta1").ignoresSafeArea())
    }
}

