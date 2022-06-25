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
    /// Interface for retrieving an instance of the service stored
    /// - Returns: An instance of the service stored
    func returnService(_ resolver: Resolver) -> Any
}

// MARK: - Permanent
/// A wrapper encapsulating the single instance of a registered type. This class will simply store the already instantiated type and return it when requested.
final class PermanentStore<Service>: ServiceStorage {
    /// The stored instance of the service which will be returned when requested.
    private let service: Service
    
    /// Initialiser for a permanent store of a registered service.
    /// - Parameter service: The service to be stored and returned when requested.
    init(_ service: Service) {
        self.service = service
    }
    
    /// This function returns the stored service supplied by this permanent storage wrapper class.
    /// - Parameter resolver: The resolver object to be used when resolving dependencies, however in this permanent storage type it is simple ignored.
    /// - Returns: The stored service.
    func returnService(_ resolver: Resolver) -> Any {
        return service
    }
}

// MARK: - Transient
/// A wrapper encapsulating and storing a factory method used to generate new instances (known as a service) of a registered type. The stored function accepts no arguments and simply returns a newly instantiated type per each request.
final class TransientStore<Service>: ServiceStorage {
    /// The factory method used to create an instance of the service each time it is requested.
    private let factory: (() -> Service)
    
    /// Initialiser for a transient store of a registered service.
    /// - Parameter factory: The factory method used to create an instance of the service each time it is requested.
    init(_ factory: @escaping (() -> Service)) {
        self.factory = factory
    }
    
    /// This function returns a newly created service with each function call.
    /// - Parameter resolver: The resolver object to be used when resolving dependencies, however in this transient storage type it is simple ignored.
    /// - Returns: A newly created service with each function call.
    func returnService(_ resolver: Resolver) -> Any {
        return factory()
    }
}

// MARK: - Transient With Resolver
/// A wrapper encapsulating and storing a factory method used to generate new instances (known as a service) of a registered type. The stored function accepts one arguments known as a resolver which can be used to resolve any dependencies required to instantiate each type. The stored function returns one new instance per request.
final class TransientStoreWithResolver<Service>: ServiceStorage {
    /// The factory method used to create an instance of the service each time it is requested.
    private let factory: ((Resolver) -> Service)
    
    /// Initialiser for a transient store of a registered service.
    /// - Parameter factory: The factory method used to create an instance of the service each time it is requested.
    init(_ factory: @escaping ((Resolver) -> Service)) {
        self.factory = factory
    }
    
    /// This function returns a newly created service with each function call.
    /// - Parameter resolver: The resolver object to be used when resolving dependencies for the type that is iinstantiated.
    /// - Returns: A newly created service with each function call.
    func returnService(_ resolver: Resolver) -> Any {
        return factory(resolver)
    }
}
