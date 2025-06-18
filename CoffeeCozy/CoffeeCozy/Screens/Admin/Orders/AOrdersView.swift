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
                    // SearchBar pro filtrování seznamu
                    SearchBar(text: $viewModel.searchText)

                    // Graf – vždy se zobrazuje na základě všech objednávek
                    OrderRevenueChartView(orders: viewModel.orders)
                        .padding(.horizontal)

                    // Filtrovaný seznam objednávek
                    List(viewModel.filteredOrders) { order in
                        NavigationLink {
                            AOrderDetailView(order: order, viewModel: viewModel)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(order.userName)
                                        .font(.headline)
                                    Text(order.createdAt, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(String(format: "%.2f Kč", order.totalPrice))
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
            .onAppear {
                viewModel.loadOrders()
            }
        }
    }
}
