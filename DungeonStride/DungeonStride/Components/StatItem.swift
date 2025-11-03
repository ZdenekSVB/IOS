//
//  StatItem.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


import SwiftUI

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color("Paleta2"))
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(Color("Paleta4"))
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color("Paleta3"))
        .cornerRadius(8)
    }
}

struct StatItem_Previews: PreviewProvider {
    static var previews: some View {
        StatItem(icon: "figure.walk", title: "Distance", value: "5.2 km")
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color("Paleta5"))
    }
}
