//
//  ProfileIconButton.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.06.2025.
//


import SwiftUI

struct ProfileIconButton: View {
    let imageUrl: String?
    
    var body: some View {
        NavigationLink {
            ProfileView(viewModel: ProfileViewModel())
        } label: {
            if let urlString = imageUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .clipped()
                .contentShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
                    .clipped()
                    .contentShape(Circle())
            }
        }
    }
}
