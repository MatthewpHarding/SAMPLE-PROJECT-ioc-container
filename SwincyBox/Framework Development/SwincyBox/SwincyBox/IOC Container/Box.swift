//
//  Container.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 15/06/2022.
//

import Foundation

public final class Box {
    
    // MARK: - Properties
    
    private var services: [String : ServiceStorage] = [:]
    private weak var parentBox: Box? = nil
    private var childBoxes: [String: Box] = [:]
    
    // MARK: - Exposed Public API
    
    public init () {
        
    }
    
    public var numberOfRegisteredServices: Int {
        return services.count
    }
    
    // MARK: - Clear Registered Services
    
    public func clear() {
        services.removeAll()
    }
    
    // MARK: - Register Dependecy (without a resolver)
    
    public func register<T>(_ type: T.Type = T.self, key: String? = nil, life: LifeType = .transient,_ factory: @escaping (() -> T)) {
        
        let key = generateServiceKey(for: type, key: key)
        if let _ = services[key] {
            logWarning("Already registerd '\(type)' for key '\(key)'")
        }
        
        let storage: ServiceStorage = {
            switch life {
            case .transient:
                return TransientStore(factory)
            case .permanent:
                return PermanentStore(factory())
            }
        }()
        services[key] = storage
    }
    
    // MARK: - Register Dependecy (using a resolver)
    
    public func register<T>(_ type: T.Type = T.self, key: String? = nil, life: LifeType = .transient,_ factory: @escaping ((Box) -> T)) {
        
        let key = generateServiceKey(for: type, key: key)
        if let _ = services[key] {
            logWarning("Already registerd '\(type)' for key '\(key)'")
        }
        
        let storage: ServiceStorage = {
            switch life {
            case .transient: return TransientStoreWithResolver(factory)
            case .permanent: return PermanentStore(factory(self))
            }
        }()
        services[key] = storage
    }
    
    // MARK: - Resolve Dependency
    
    public func resolve<T>(_ type: T.Type = T.self, key: String? = nil) -> T {
        return resolveUsingParentIfNeeded(type, key: key)
    }
    
    // MARK: - Childbox
    
    public func addChildBox(forKey key: String) -> Box {
        let box = Box()
        box.parentBox = self
        box.services = services // copies a snapshot of the existing dictionary. instances remain the same
        if let _ = childBoxes[key] {
            logWarning("Already registerd childBox for key '\(key)'")
        }
        childBoxes[key] = box
        return box
    }
    
    public func childBox(forKey key: String) -> Box? {
        guard let childBox = childBoxes[key] else {
            logWarning("Child box not found for key '\(key)'")
            return nil
        }
        
        return childBox
    }
    
    // MARK: - Internally Resolve Dependency
    
    private func attempToResolve<T>(_ type: T.Type = T.self, key: String? = nil) -> T? {
        let key = generateServiceKey(for: type, key: key)
        guard let storage = services[key] else {
            return nil
        }
        return storage.returnService(self) as? T
    }
    
    private func resolveUsingParentIfNeeded<T>(_ type: T.Type = T.self, key: String? = nil) -> T {
        
        if let foundService: T = attempToResolve(type, key: key) {
            return foundService
        }
        
        guard let box = parentBox else {
            fatalError("SwincyBox: Dependency not registered for type '\(type)'")
        }
        
        return box.resolveUsingParentIfNeeded(type, key: key)
    }
    
    // MARK: - Services Key Generation
    
    private func generateServiceKey<T>(for type: T, key: String?) -> String {
        guard let name = key else {
            return "\(type)"
        }
        return "\(type) - \(name)"
    }
}

// MARK: - Logging

/// Logging will only occur during a development build and not within a release build to ensure the performance of client apps is maintained and supported
extension Box {
    
    private func log(_ string: String) {
        // NOTE: Printing to the console slows down performance of the app and device. We never want to negatively effect the performance of our client apps even for logging warnings
        #if DEBUG
        print("Swincy Framework")
        print(string)
        #endif
    }
    
    private func logWarning(_ string: String) {
        log("Warning: " + string)
    }
}
