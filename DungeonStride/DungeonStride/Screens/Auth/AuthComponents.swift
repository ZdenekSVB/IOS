//
//  AuthComponents.swift
//  DungeonStride
//

import SwiftUI

struct AuthHeaderView: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color("Paleta2"))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color("Paleta4"))
            }
        }
    }
}

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

struct AuthButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .background(Color("Paleta2"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct WelcomeButton: View {
    let title: String
    let icon: String
    var isSystemImage: Bool = true
    let color: Color
    var textColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isSystemImage {
                    Image(systemName: icon)
                } else {
                    Image(icon).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20)
                }
                Text(title).fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}
