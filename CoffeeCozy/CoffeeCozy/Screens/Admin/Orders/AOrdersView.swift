import SwiftUI
import Charts

struct AOrdersView: View {
    @StateObject private var viewModel = AOrdersViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.orders.isEmpty {
                    if !viewModel.errorMessage.isEmpty {
                        VStack {
                            Text(viewModel.errorMessage)
                                .font(.headline)
                            Button("Try Again") {
                                viewModel.loadOrders()
                            }
                            .padding()
                        }
                    } else {
                        Text("No orders found")
                    }
                } else {
                    List(viewModel.filteredOrders) { order in
                        NavigationLink {
                            AOrderDetailView(order: order)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(order.displayUserName)
                                        .font(.headline)
                                    Text(order.createdAt, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                // Zobraz calculatedTotal místo order.total
                                Text(String(format: "%.2f Kč", order.calculatedTotal))
                                    .font(.subheadline).bold()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar {
                AdminToolbar()
            }
            .background(Color("Paleta1").ignoresSafeArea())
            .navigationTitle("Orders")
            .onAppear {
                viewModel.loadOrders()
            }
        }
    }
}
