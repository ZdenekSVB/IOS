//
//  ProfileView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color("Paleta3").ignoresSafeArea()
            VStack {
                Text("Profile")
                    .font(.title)
                    .foregroundColor(.white)
                Text(authViewModel.currentUserEmail ?? "User")
                    .foregroundColor(Color("Paleta4"))
                
                Button("Logout") {
                    authViewModel.logout()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
                .padding(.top, 20)
            }
        }
    }
}
