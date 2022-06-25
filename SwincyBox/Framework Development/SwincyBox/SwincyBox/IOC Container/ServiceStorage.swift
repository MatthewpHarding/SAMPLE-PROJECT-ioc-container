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

final class PermanentStore<T>: ServiceStorage {
    
    private let service: T
    let storageType: ServiceStorageType = .permanent
    
    init(_ service: T) {
        self.service = service
    }
    
    func returnService(_ resolver: Box) -> Any {
        return service
    }
}

// MARK: - Transient

final class TransientStore<T>: ServiceStorage {
    
    private let factory: (() -> T)
    let storageType: ServiceStorageType = .transient

    init(_ factory: @escaping (() -> T)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Box) -> Any {
        return factory()
    }
}

// MARK: - Transient With Resolver

final class TransientStoreWithResolver<T>: ServiceStorage {
    
    private let factory: ((Box) -> T)
    let storageType: ServiceStorageType = .transientWithResolver

    init(_ factory: @escaping ((Box) -> T)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Box) -> Any {
        return factory(resolver)
    }
}


