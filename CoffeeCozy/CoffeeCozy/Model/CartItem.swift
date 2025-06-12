//
//  CartItem.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//

import Foundation
import UIKit

struct CartItem: Identifiable {
    let id = UUID()
    let item: SortimentItem
    var quantity: Int
}
