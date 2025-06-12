
//  SortimentTile.swift
//  CoffeeCozy

import SwiftUI

struct SortimentTile: View {
    let item: SortimentItem

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
                    Text("\(item.price, specifier: "%.0f")$")
                        .font(.title3)
                        .bold()

                    Spacer()

                    Button {
                        // zde případná akce pro úpravu
                    } label: {
                        Image(systemName: "pencil")
                            .padding(10)
                            .background(Circle().fill(Color.orange))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        }
}
