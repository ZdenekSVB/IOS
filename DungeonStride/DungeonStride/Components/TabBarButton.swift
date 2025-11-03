//
//  TabBarButton.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


//
//  TabBarButton.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color("Paleta2") : Color("Paleta4"))
                
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? Color("Paleta2") : Color("Paleta4"))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct TabBarButton_Previews: PreviewProvider {
    static var previews: some View {
        TabBarButton(
            icon: "house.fill",
            title: "Home",
            isSelected: true,
            action: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}