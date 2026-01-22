//
//  Injected.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T
    
    // ZDE BYLA CHYBA: Odstraněno @MainActor
    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}
