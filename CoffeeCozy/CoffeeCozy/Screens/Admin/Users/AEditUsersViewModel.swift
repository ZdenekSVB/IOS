// EditUserViewModel.swift

import SwiftUI
import PhotosUI

class AEditUserViewModel: ObservableObject {
    @Published var username: String
    @Published var firstname: String
    @Published var lastname: String
    @Published var phoneNumber: String
    @Published var email: String
    @Published var password: String
    @Published var image: UIImage?
    @Published var selectedImageItem: PhotosPickerItem? {
        didSet { loadImage() }
    }

    let isEditing: Bool
    private let originalUser: User?

    init(user: User? = nil) {
        if let u = user {
            self.username = u.username
            self.firstname = u.firstname
            self.lastname = u.lastname
            self.phoneNumber = u.phoneNumber
            self.email = u.email
            self.password = u.password
            self.image = u.image
            self.isEditing = true
            self.originalUser = u
        } else {
            self.username = ""
            self.firstname = ""
            self.lastname = ""
            self.phoneNumber = ""
            self.email = ""
            self.password = ""
            self.image = nil
            self.isEditing = false
            self.originalUser = nil
        }
    }

    var isValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty
    }

    func save() {
        // TODO: Save to Firestore
        if isEditing {
            print("Update user \(username)")
        } else {
            print("Create user \(username)")
        }
    }

    private func loadImage() {
        Task {
            if let data = try? await selectedImageItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                }
            }
        }
    }
}
