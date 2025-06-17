import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var firstname: String
    var lastname: String
    var phoneNumber: String
    var email: String
    var imageUrl: String?
    var role: String // "user" or "admin"
    var createdAt: Date?
    var updatedAt: Date?
}
