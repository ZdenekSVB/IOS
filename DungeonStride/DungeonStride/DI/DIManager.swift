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
        
        // 1. AuthService
        register(AuthService.self, cached: true) {
            MainActor.assumeIsolated {
                AuthService()
            }
        }
        
        // 2. UserService
        register(UserService.self, cached: true) {
            MainActor.assumeIsolated {
                UserService()
            }
        }
        
        // 3. ThemeManager
        register(ThemeManager.self, cached: true) {
            MainActor.assumeIsolated {
                ThemeManager()
            }
        }
        
        // 4. Managers
        register(ActivityManager.self, cached: true) {
            ActivityManager()
        }
        
        register(HapticManager.self, cached: true) {
            HapticManager.shared
        }
        
        register(LocationManager.self, cached: true) {
            LocationManager()
        }
        
        // PŘIDÁNO: NotificationManager
        register(NotificationManager.self, cached: true) {
            NotificationManager.shared
        }
        
        // 5. Other Services
        register(QuestService.self, cached: true) {
            QuestService()
        }
        
        register(DungeonMapService.self, cached: true) {
            MainActor.assumeIsolated {
                DungeonMapService()
            }
        }
        
        register(ItemsService.self, cached: true) {
            MainActor.assumeIsolated {
                ItemsService()
            }
        }
        
        register(EnemyService.self, cached: true) {
            MainActor.assumeIsolated {
                EnemyService()
            }
        }
    }
}

