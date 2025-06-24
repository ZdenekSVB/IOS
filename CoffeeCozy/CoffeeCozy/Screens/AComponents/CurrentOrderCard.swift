//
//  OrdersHomeCard.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 24.06.2025.
//
import SwiftUI
import Foundation

struct CurrentOrderCard: View {
    let order: OrderRecord
    let estimatedTime: Int
    let onLocationTap: () -> Void
    
    enum OrderStatusStep: Int {
        case pending = 0
        case preparing
        case finished
    }

    var orderStep: OrderStatusStep {
        switch order.status.lowercased() {
        case "pending":
            return .pending
        case "preparing":
            return .preparing
        case "finished":
            return .finished
        default:
            return .pending
        }
    }
    
    var statusText: String {
        switch orderStep {
        case .pending:
            return "Your order is pending"
        case .preparing:
            return "Your order is currently being prepared"
        case .finished:
            return "Your order is ready for pickup!"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Order")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            OrderProgressView(step: orderStep.rawValue)

            Text(statusText)
                .font(.body)
                .foregroundColor(.black)
            
            Text("Estimated time: \(estimatedTime) minutes")
                .font(.body)
                .foregroundColor(.black)
            
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(order.items, id: \.name) { item in
                        Text("\(item.quantity)x \(item.name)")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    
                    Text("Total: \(String(format: "%.0f", order.totalPrice))$")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: onLocationTap) {
                    NavigationLink("Find us") {
                        MapView(viewModel: MapViewModel())
                    }
                    .padding()
                    .background(Color("Paleta3"))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
            }
        }
        .padding(20)
        .background(Color.yellow.opacity(0.3))
        .cornerRadius(20)
        
    }
}

struct OrderProgressView: View {
    let step: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                progressCircle(isFilled: index <= step)
                
                if index < 2 {
                    progressLine(isFilled: index < step)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func progressCircle(isFilled: Bool) -> some View {
        if isFilled {
            Circle()
                .fill(Color.green)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                )
        }
    }

    private func progressLine(isFilled: Bool) -> some View {
        Rectangle()
            .fill(isFilled ? Color.green : Color.gray.opacity(0.3))
            .frame(width: 30, height: 4)
    }
}
