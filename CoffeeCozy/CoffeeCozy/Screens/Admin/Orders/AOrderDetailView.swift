import SwiftUI

struct AOrderDetailView: View {
    let order: OrderRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header s ID, uživatelem, daty a totalem
            VStack(alignment: .leading, spacing: 8) {
                Text("Order #\(order.id.prefix(8))")
                    .font(.title2.bold())
                
                HStack {
                    Image(systemName: "person.fill")
                    Text(order.displayUserName)
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text("Created: \(order.createdAt.formatted(date: .abbreviated, time: .shortened))")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Completed: \(order.finishedAt.formatted(date: .abbreviated, time: .shortened))")
                }
                
                HStack {
                    Image(systemName: "creditcard.fill")
                    Text("Total: \(order.calculatedTotal, specifier: "%.2f") Kč") // tady calculatedTotal
                        .font(.headline)
                }
            }
            .padding()
            .background(Color("Paleta2"))
            .cornerRadius(12)
            
            // Seznam položek objednávky
            if !order.items.isEmpty {
                List {
                    Section(header: Text("Order Items")) {
                        ForEach(order.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name.isEmpty ? "Unknown Item" : item.name)
                                        .font(.headline)
                                    Text("\(item.quantity)x \(item.price, specifier: "%.2f") Kč")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(item.totalPrice, specifier: "%.2f") Kč")
                                        .bold()
                                    Text(item.status.isEmpty ? "unknown" : item.status.capitalized)
                                        .font(.caption)
                                        .foregroundColor(statusColor(for: item.status))
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                Text("No items in this order")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(Color("Paleta1").ignoresSafeArea())
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "completed": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}
