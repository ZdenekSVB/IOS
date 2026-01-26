//
//  AuthTextField.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//
import SwiftUI


struct AuthTextField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            if isSecure {
                SecureField("Enter your \(title.lowercased())", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
            } else {
                TextField("Enter your \(title.lowercased())", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
    }
}
