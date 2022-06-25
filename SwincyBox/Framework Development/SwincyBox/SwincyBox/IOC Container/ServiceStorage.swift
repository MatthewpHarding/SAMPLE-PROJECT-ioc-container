//
//  Services.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 17/06/2022.
//

import Foundation

// MARK: - Protocol

protocol ServiceStorage {
    func returnService(_ resolver: Resolver) -> Any
}

// MARK: - Permanent

final class PermanentStore<Service>: ServiceStorage {
    
    private let service: Service
    
    init(_ service: Service) {
        self.service = service
    }
    
    func returnService(_ resolver: Resolver) -> Any {
        return service
    }
}

// MARK: - Transient

final class TransientStore<Service>: ServiceStorage {
    
    private let factory: (() -> Service)

    init(_ factory: @escaping (() -> Service)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Resolver) -> Any {
        return factory()
    }
}

// MARK: - Transient With Resolver

final class TransientStoreWithResolver<Service>: ServiceStorage {
    
    private let factory: ((Resolver) -> Service)

    init(_ factory: @escaping ((Resolver) -> Service)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Resolver) -> Any {
        return factory(resolver)
    }
}


