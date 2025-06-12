//
//  OrdersView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 27.05.2025.
//

import SwiftUI
import ImageIO

struct SortimentView: View {
    @StateObject private var viewModel = SortimentViewModel()
    
    let columns = [
           GridItem(.flexible()),
           GridItem(.flexible())
       ]

       var body: some View {
           NavigationView {
               ScrollView {
                   LazyVGrid(columns: columns, spacing: 20) {
                       ForEach(viewModel.items) { item in
                           SortimentTile(item: item)
                       }
                   }
                   .padding()
               }
               .navigationTitle("Sortiment")
               .background(Color("paleta1").ignoresSafeArea()) // pokud máš světlé pozadí
           }
       }
}
