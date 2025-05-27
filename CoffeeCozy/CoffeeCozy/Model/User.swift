import Foundation
import UIKit

// MARK: - Uživatelský Model

struct User: Identifiable {
    var id: UUID
    var username: String
    var lastname: String
    var firstname: String
    var phoneNumber: String
    var email: String
    var password: String
    var image: UIImage

    static let sample1 = User(
        id: UUID(),
        username: "jdoe",
        lastname: "Doe",
        firstname: "John",
        phoneNumber: "+420123456789",
        email: "jdoe@example.com",
        password: "securePassword123",
        image: UIImage(named: "user1") ?? UIImage()
    )

    static let sample2 = User(
        id: UUID(),
        username: "asmith",
        lastname: "Smith",
        firstname: "Alice",
        phoneNumber: "+420987654321",
        email: "asmith@example.com",
        password: "anotherSecurePass",
        image: UIImage(named: "user2") ?? UIImage()
    )

    static let samples = [sample1, sample2]
}
