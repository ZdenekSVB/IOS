import Foundation
import UIKit

// MARK: - Produktový Model

enum ProductCategory: Int16, CaseIterable, Identifiable {
    var id: Self { self }

    case Electronics = 1
    case Furniture = 2
    case Clothing = 3

    var name: String {
        switch self {
        case .Electronics: return "Electronics"
        case .Furniture: return "Furniture"
        case .Clothing: return "Clothing"
        }
    }
}

struct Product: Identifiable {
    var id: UUID
    var name: String
    var description: String
    var price: Double
    var category: ProductCategory
    var image: UIImage

    static let sample1 = Product(
        id: UUID(),
        name: "Smartphone",
        description: "Latest generation smartphone with stunning display.",
        price: 799.99,
        category: .Electronics,
        image: UIImage(named: "smartphone") ?? UIImage()
    )

    static let sample2 = Product(
        id: UUID(),
        name: "Sofa",
        description: "Comfortable 3-seater sofa in grey color.",
        price: 549.90,
        category: .Furniture,
        image: UIImage(named: "sofa") ?? UIImage()
    )

    static let samples = [sample1, sample2]
}
