
//  SortimentTile.swift
//  CoffeeCozy

import SwiftUI

struct SortimentTile: View {
    let item: SortimentItem
    var onEdit: () -> Void
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: item.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(12)

            Text(item.name)
                .font(.headline)

            Text(item.category)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("\(item.price, specifier: "%.0f") Kč")
                    .font(.title3)
                    .bold()

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        .onTapGesture {
            onTap()
        }
    }
}
