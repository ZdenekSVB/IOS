import SwiftUI
struct SortimentTile: View {
    let item: SortimentItem
    let isAdmin: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onAddToCart: () -> Void
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: item.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 120)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.2)
                    .frame(width: 160, height: 120)
            }
            .cornerRadius(16)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(item.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal)

            Spacer()

            HStack {
                Text("\(item.price, specifier: "%.2f")$")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                if isAdmin {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onAddToCart) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(width: 180, height: 250)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .contextMenu {
            if isAdmin {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Smazat", systemImage: "trash")
                }
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}


/*
struct SortimentTile: View {
    let item: SortimentItem
    let isAdmin: Bool
    var onEdit: () -> Void
    var onAddToCart: () -> Void
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Obrázek
            AsyncImage(url: URL(string: item.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(16)
            .padding(.top, 8)

            // Texty
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(item.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal)

            Spacer()

            // Cena a tlačítko
            HStack {
                Text("\(item.price)$")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                if isAdmin {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onAddToCart) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(width: 180, height: 250)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onTapGesture {
            onTap()
        }
    }
}
*/
