//
//  Injected.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 23.06.2025.
//

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T

    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}
