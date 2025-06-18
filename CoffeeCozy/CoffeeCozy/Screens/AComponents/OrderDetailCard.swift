import SwiftUI
import FirebaseFirestore

struct OrderDetailCard: View {
    @State private var showStatusDialog = false
    @ObservedObject var viewModel: AOrdersViewModel
    var order: OrderRecord

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Order #\(order.id?.prefix(6) ?? "N/A")")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                
                Button {
                    if order.status.lowercased() == "pending" {
                        showStatusDialog = true
                    }
                } label: {
                    Text(order.status.capitalized)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(statusColor)
                        .clipShape(Capsule())
                }
                .disabled(order.status.lowercased() != "pending")
                .confirmationDialog("Change Order Status", isPresented: $showStatusDialog) {
                    Button("Mark as Finished") {
                        viewModel.updateOrderStatus(orderId: order.id, newStatus: "finished")
                    }
                    Button("Mark as Canceled", role: .destructive) {
                        viewModel.updateOrderStatus(orderId: order.id, newStatus: "canceled")
                    }
                }
            }
            .padding()
            .background(Color.brown)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 8) {
                Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                ForEach(order.items) { item in
                    HStack {
                        Text("\(item.quantity)x \(item.name)")
                        Spacer()
                        Text(String(format: "%.2f Kč", item.price * Double(item.quantity)))
                    }
                }

                Divider()

                HStack {
                    Text("Total:")
                        .bold()
                    Spacer()
                    Text(String(format: "%.2f Kč", order.totalPrice))
                        .bold()
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding()
    }

    private var statusColor: Color {
        switch order.status.lowercased() {
        case "pending": return .orange
        case "finished", "completed": return .green
        case "canceled": return .red
        default: return .gray
        }
    }
}
