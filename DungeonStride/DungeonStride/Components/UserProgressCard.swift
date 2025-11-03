//
//  UserProgressCard.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//



import SwiftUI

struct UserProgressCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("Paleta2"))
                
                VStack(alignment: .leading) {
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(Color("Paleta4"))
                    Text(authViewModel.currentUserEmail ?? "User")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Level badge
                VStack {
                    Text("Lvl")
                        .font(.caption2)
                        .foregroundColor(Color("Paleta4"))
                    Text("5")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Paleta2"))
                }
            }
            
            // XP Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to next level")
                        .font(.caption)
                        .foregroundColor(Color("Paleta4"))
                    Spacer()
                    Text("1,250 / 2,000 XP")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                // Progress Bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("Paleta5"))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color("Paleta2"))
                        .frame(width: 125, height: 8) // 1250/2000 = 62.5%
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color("Paleta5"))
        .cornerRadius(12)
    }
}

struct UserProgressCard_Previews: PreviewProvider {
    static var previews: some View {
        UserProgressCard()
            .environmentObject(AuthViewModel())
            .previewLayout(.sizeThatFits)
    }
}
