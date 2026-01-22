//
//  DIManager.swift
//  DungeonStride
//

import Foundation

final class DIContainer {
    typealias Resolver = () -> Any
    
    private var resolvers = [String: Resolver]()
    private var cache = [String: Any]()
    
    static let shared = DIContainer()
    
    init() {
        registerDependencies()
    }
    
    func register<T, R>(_ type: T.Type, cached: Bool = false, service: @escaping () -> R) {
        let key = String(reflecting: type)
        resolvers[key] = service
        
        if cached {
            cache[key] = service()
        }
    }
    
    func resolve<T>() -> T {
        let key = String(reflecting: T.self)
        
        if let cachedService = cache[key] as? T {
            return cachedService
        }
        
        if let resolver = resolvers[key], let service = resolver() as? T {
            return service
        }
        
        fatalError("🥣 \(key) has not been registered.")
    }
}

extension DIContainer {
    func registerDependencies() {
        // 1. Activity Manager
        register(ActivityManager.self, cached: true) {
            ActivityManager()
        }
        
        // 2. Haptic Manager (Singleton)
        register(HapticManager.self, cached: true) {
            HapticManager.shared
        }
        
        // 3. Location Manager
        // Registrujeme ho, kdybychom ho potřebovali injectnout jinam než do ActivityManageru
        register(LocationManager.self, cached: true) {
            LocationManager()
        }
        
        // Poznámka: Ostatní služby jako UserService, AuthViewModel, ThemeManager
        // jsou v této architektuře inicializovány v App jako @StateObject a předávány
        // přes .environmentObject, což je pro SwiftUI ViewModels správně.
        // Pokud bys je chtěl mít zde, museli bychom změnit inicializaci v DungeonStrideApp.swift.
    }
}
