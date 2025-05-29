
//  SortimentTile.swift
//  CoffeeCozy

import SwiftUI

struct SortimentTile: View {
    let item: SortimentItem
    let isAdmin: Bool
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(8)
                case .failure:
                    Color.gray
                        .frame(height: 100)
                        .cornerRadius(8)
                @unknown default:
                    EmptyView()
                }
            }

            Text(item.name)
                .font(.headline)

            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Text(String(format: "%.2f Kč", item.price))
                    .fontWeight(.bold)

                Spacer()

                NavigationLink {
                    AEditSortimentView(viewModel: AEditSortimentViewModel(item: item))
                } label: {
                    Image(systemName: isAdmin ? "pencil" : "plus")
                        .padding(8)
                        .background(Color("Paleta2"))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
