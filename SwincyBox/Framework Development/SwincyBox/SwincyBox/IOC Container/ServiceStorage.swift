//
//  Services.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 17/06/2022.
//

import Foundation


// MARK: - Protocol

protocol ServiceStorage {
    
    var storageType: ServiceStorageType { get }
    func returnService(_ resolver: Box) -> Any
}

enum ServiceStorageType {
    
    case permanent
    case transient
    case transientWithResolver
}

// MARK: - Permanent

final class PermanentStore<Service>: ServiceStorage {
    
    private let service: Service
    let storageType: ServiceStorageType = .permanent
    
    init(_ service: Service) {
        self.service = service
    }
    
    func returnService(_ resolver: Box) -> Any {
        return service
    }
}

// MARK: - Transient

final class TransientStore<Service>: ServiceStorage {
    
    private let factory: (() -> Service)
    let storageType: ServiceStorageType = .transient

    init(_ factory: @escaping (() -> Service)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Box) -> Any {
        return factory()
    }
}

// MARK: - Transient With Resolver

final class TransientStoreWithResolver<Service>: ServiceStorage {
    
    private let factory: ((Box) -> Service)
    let storageType: ServiceStorageType = .transientWithResolver

    init(_ factory: @escaping ((Box) -> Service)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Box) -> Any {
        return factory(resolver)
    }
}


