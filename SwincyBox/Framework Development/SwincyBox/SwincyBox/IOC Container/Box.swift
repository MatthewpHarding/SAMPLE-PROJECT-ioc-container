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
    weak var parentBox: Box? = nil
    private var childBoxes: [String: Box] = [:]
    
    // MARK: - Exposed Public API
    
    public init () {
        
    }
    
    public var numberOfRegisteredServices: Int {
        return services.count
    }
    
    // MARK: - Clear All Services
    
    public func clear() {
        services.removeAll()
    }
    
    // MARK: - Registration (without a resolver)
   
    public func register<T>(_ type: T.Type = T.self, key: String? = nil, life: LifeType = .transient,_ factory: @escaping (() -> T)) {
        
        let key = generateKey(for: type, key: key)
        if let _ = services[key] {
            logAlreadyRegisteredType(forKey: key, type)
        }
        
        let storage: ServiceStorage = {
            switch life {
            case .transient:
                return TransientStorage(factory)
            case .permanent:
                return PermanentStorage(factory())
            }
        }()
        services[key] = storage
    }
    
    // MARK: - Registration (using a resolver)
    
    public func register<T>(_ type: T.Type = T.self, key: String? = nil, life: LifeType = .transient,_ factory: @escaping ((Box) -> T)) {
        
        let key = generateKey(for: type, key: key)
        if let _ = services[key] {
            logAlreadyRegisteredType(forKey: key, type)
        }
        
        let storage: ServiceStorage = {
            switch life {
            case .transient:
                return TransientStorageWithResolver(factory)
            case .permanent:
                return PermanentStorage(factory(self))
            }
        }()
        services[key] = storage
    }
    
    // MARK: - Childbox
    
    public func addChildBox(forKey key: String) -> Box {
        let box = Box()
        box.parentBox = self
        box.services = services // copies a snapshot of the existing dictionary. instances remain the same
        if let _ = childBoxes[key] {
            logAlreadyRegisteredChildBox(forKey: key)
        }
        childBoxes[key] = box
        return box
    }
    
    public func childBox(forKey key: String) -> Box? {
        guard let childBox = childBoxes[key] else {
            logChildBoxNotFound(forKey: key)
            return nil
        }
        
        return childBox
    }
    
    // MARK: - Resolution
    
    public func resolve<T>(_ type: T.Type = T.self, key: String? = nil) -> T {
        return resolveUsingParentIfNeeded(type, key: key)
        
        /*
        let key = generateKey(for: type, key: key)
        guard let storage = services[key] else {
            logResolutionFailure(forKey: key, type)
            fatalError("SwincyBox: Dependency not registered for type '\(T.self)'")
        }
        
        switch storage {
        case let storage as TransientStorageWithResolver<T>:
            return storage.constructService(self)
            
        case let storage as TransientStorage<T>:
            return storage.constructService()
            
        case let storage as PermanentStorage<T>:
            return storage.service
            
        default: fatalError("SwincyBox: Unsupported storage type")
        }
         */
    }
    
    public func attempToResolve<T>(_ type: T.Type = T.self, key: String? = nil) -> T? {
        let key = generateKey(for: type, key: key)
        guard let storage = services[key] else {
            return nil
        }
        
        switch storage {
        case let storage as TransientStorageWithResolver<T>:
            return storage.constructService(self)
            
        case let storage as TransientStorage<T>:
            return storage.constructService()
            
        case let storage as PermanentStorage<T>:
            return storage.service
            
        default: fatalError("SwincyBox: Unsupported storage type")
        }
    }
    
    private func resolveUsingParentIfNeeded<T>(_ type: T.Type = T.self, key: String? = nil) -> T {
        
        if let foundService: T = attempToResolve(type, key: key) {
            return foundService
        }
        
        // parent box
        guard let box = parentBox else {
            fatalError("SwincyBox: Dependency not registered for type '\(T.self)'")
        }
        
        return box.resolveUsingParentIfNeeded(type, key: key)
    }
    
    // MARK: - Services Key Generation
    
    private func generateKey<T>(for type: T, key: String?) -> String {
        guard let name = key else {
            return "\(type)"
        }
        return "\(type) - \(name)"
    }
}

// MARK: - Logging

extension Box {
    
    private func logResolutionFailure<T>(forKey key: String, _ type: T) {
        print("Swincy Framework")
        print("Error: Couldn't resolve type '\(type)' for key '\(key)'")
    }
    
    private func logAlreadyRegisteredType<T>(forKey key: String, _ type: T) {
        print("Swincy Framework")
        print("Warning: Already registerd '\(type)' for key '\(key)'")
    }
    
    private func logAlreadyRegisteredChildBox(forKey key: String) {
        print("Swincy Framework")
        print("Warning: Already registerd childBox for key '\(key)'")
    }
    
    private func logChildBoxNotFound(forKey key: String) {
        print("Swincy Framework")
        print("Warning: Child box not found for key '\(key)'")
    }
}
