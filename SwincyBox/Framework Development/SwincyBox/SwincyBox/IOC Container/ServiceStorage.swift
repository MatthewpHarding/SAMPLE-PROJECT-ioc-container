//
//  Services.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 17/06/2022.
//

import Foundation

// MARK: - Protocol
/// This protocol declares an interface to retrieve a registered service from a storage wrapper, which either generates, instantiates or provides single access to the service it encapsulates or generates. A method is simply called to return the associated service. How the service is stored or instantiated is of no importance here.
protocol ServiceStorage {
    func returnService(_ resolver: Resolver) -> Any
}

// MARK: - Permanent
/// A wrapper encapsulating the single instance of a registered type. This class will simply store the already instantiated type and return it when requested.
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
/// A wrapper encapsulating and storing a factory method used to generate new instances (known as a service) of a registered type. The stored function accepts no arguments and simply returns a newly instantiated type per each request.
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
/// A wrapper encapsulating and storing a factory method used to generate new instances (known as a service) of a registered type. The stored function accepts one arguments known as a resolver which can be used to resolve any dependencies required to instantiate each type. The stored function returns one new instance per request.
final class TransientStoreWithResolver<Service>: ServiceStorage {
    private let factory: ((Resolver) -> Service)

    init(_ factory: @escaping ((Resolver) -> Service)) {
        self.factory = factory
    }
    
    func returnService(_ resolver: Resolver) -> Any {
        return factory(resolver)
    }
}
