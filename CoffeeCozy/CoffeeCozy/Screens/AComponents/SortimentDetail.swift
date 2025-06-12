//
//  SortimentDetailView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 12.06.2025.
//


import SwiftUI

struct SortimentDetail: View {
    let item: SortimentItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: item.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView().frame(height: 180)
                case .success(let img):
                    img.resizable()
                       .scaledToFit()
                       .frame(height: 180)
                       .cornerRadius(12)
                case .failure:
                    Color.gray.frame(height: 180).cornerRadius(12)
                @unknown default:
                    EmptyView()
                }
            }

            Text(item.name).font(.title2).bold()
            Text(item.desc).font(.body).padding(.horizontal)
            Text(String(format: "%.2f Kč", item.price)).font(.title3)
            Button("Zavřít") { dismiss() }.padding()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}
