//
//  SearchBar.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("Search...", text: $text)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding([.horizontal, .top])
    }
}
