// User.swift

import SwiftUI

struct User: Identifiable {
    var id: UUID
    var username: String
    var lastname: String
    var firstname: String
    var phoneNumber: String
    var email: String
    var password: String
    var image: UIImage
}
