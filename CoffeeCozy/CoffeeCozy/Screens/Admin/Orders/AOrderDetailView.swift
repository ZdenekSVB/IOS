import SwiftUI

struct AOrderDetailView: View {
    let order: OrderRecord
    @ObservedObject var viewModel: AOrdersViewModel
    
    var body: some View {
        ZStack {
            Color("Paleta1")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                OrderDetailCard(viewModel: viewModel, order: order)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

