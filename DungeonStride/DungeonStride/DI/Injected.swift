//
//  Injected.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T

    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}
