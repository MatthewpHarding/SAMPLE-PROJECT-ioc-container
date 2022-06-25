//
//  Container.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 15/06/2022.
//

import Foundation

/// Resolver typealias has been used to aid the documentation and readability of the code by using standardised IOC Framework terminology
public typealias Resolver = Box

public final class Box {
    
    // MARK: - Properties
    
    private var services: [String : ServiceStorage] = [:]
    private weak var parentBox: Box? = nil
    private var childBoxes: [String: Box] = [:]
    
    // MARK: - Exposed Public API
    
    public var registeredServiceCount: Int { return services.count }
    
    public init () { }
    
    // MARK: - Clear Registered Services
    
    public func clear() {
        services.removeAll()
    }
    
    // MARK: - Register Dependecy (without a resolver)
    
    public func register<Service>(_ type: Service.Type = Service.self, key: String? = nil, life: LifeType = .transient, _ factory: @escaping (() -> Service)) {
        registerServiceStore(wrapServiceFactory(factory, life: life), type, key)
    }
    
    // MARK: - Register Dependecy (using a resolver)
    
    public func register<Service>(_ type: Service.Type = Service.self, key: String? = nil, life: LifeType = .transient, _ factory: @escaping ((Resolver) -> Service)) {
        registerServiceStore(wrapServiceFactory(factory, life: life), type, key)
    }
    
    private func registerServiceStore<Service>(_ serviceStore: ServiceStorage, _ type: Service.Type, _ key: String?) {
        let serviceKey = serviceKey(for: type, key: key)
        if let _ = services[serviceKey] {
            logWarning("Already registerd '\(type)' for key '\(String(describing: key))'")
        }
        services[serviceKey] = serviceStore
    }
    
    // MARK: - Resolve Dependency
    
    public func resolve<Service>(_ type: Service.Type = Service.self, key: String? = nil) -> Service {
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
    
    private func attempToResolve<Service>(_ type: Service.Type = Service.self, key: String? = nil) -> Service? {
        guard let storage = services[serviceKey(for: type, key: key)] else { return nil }
        return storage.returnService(self) as? Service
    }
    
    private func resolveUsingParentIfNeeded<Service>(_ type: Service.Type = Service.self, key: String? = nil) -> Service {
        guard let service = attempToResolve(type, key: key) ?? parentBox?.resolveUsingParentIfNeeded(type, key: key) else {
            fatalError("SwincyBox: Dependency not registered for type '\(type)'")
        }
        return service
    }
    
    // MARK: - Service Storage
    
    private func serviceKey<Service>(for type: Service, key: String?) -> String {
        guard let key = key else { return "\(type)" }
        return "\(type) - \(key)"
    }
    
    private func wrapServiceFactory<Service>(_ factory: @escaping ((Resolver) -> Service), life: LifeType) -> ServiceStorage {
        switch life {
        case .transient: return TransientStoreWithResolver(factory)
        case .permanent: return PermanentStore(factory(self))
        }
    }
    
    private func wrapServiceFactory<Service>(_ factory: @escaping (() -> Service), life: LifeType) -> ServiceStorage {
        switch life {
        case .transient: return TransientStore(factory)
        case .permanent: return PermanentStore(factory())
        }
    }
}

// MARK: - Logging

/// Logging will only occur during a development build and not within a release build to ensure the performance of client apps is maintained and supported
extension Box {
    
    private func log(_ string: String) {
        // NOTE: Printing to the console slows down performance of the app and device. We never want to negatively affect the performance of our client apps even for logging warnings
        #if DEBUG
        print("Swincy Framework")
        print(string)
        #endif
    }
    
    private func logWarning(_ string: String) {
        log("Warning: " + string)
    }
}
