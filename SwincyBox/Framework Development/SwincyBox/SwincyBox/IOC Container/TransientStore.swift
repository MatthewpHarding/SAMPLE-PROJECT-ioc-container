//
//  TransientStore.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 06/07/2022.
//

import Foundation

/// A wrapper encapsulating and storing a factory method used to generate new instances (known as a service) of a registered type. The stored function accepts no arguments and simply returns a newly instantiated type per each request.
final class TransientStore<Service>: ServiceStoring {
    /// The factory method used to create an instance of the service each time it is requested.
    private let factory: ((Resolver) -> Service)
    /// The stored higher-order property called immediately after creation of each service.
    private var closureOnInitialise: ((Box, Any) -> Void)?
    
    /// Initialiser for a transient store of a registered service.
    /// - Parameter factory: The factory method used to create an instance of the service each time it is requested.
    init(_ factory: @escaping ((Resolver) -> Service)) {
        self.factory = factory
    }
    
    /// This function returns a newly created service with each function call.
    /// - Parameter resolver: The resolver object to be used when resolving dependencies.
    /// - Returns: A newly created service with each function call.
    func service(_ resolver: Resolver) -> Any {
        let newService = factory(resolver)
        closureOnInitialise?(resolver, newService)
        return newService
    }
    
    /// call this function to set a closure called immediately after the creation of each service.
    func onInitialised(_ closure: @escaping ((Box, Any) -> Void)) {
        closureOnInitialise = closure
    }
}
