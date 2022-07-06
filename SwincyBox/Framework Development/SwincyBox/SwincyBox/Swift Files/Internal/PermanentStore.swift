//
//  PermanentStore.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 06/07/2022.
//

import Foundation

/// A wrapper encapsulating the single instance of a registered type. This class will simply store the already instantiated type and return it when requested.
final class PermanentStore<Service>: ServiceStoring {
    /// The stored instance of the service which will be returned when requested.
    private var service: Service?
    /// The factory method used to create an instance of the service
    private let factory: ((Resolver) -> Service)
    
    /// The stored higher-order property called immediately after creation of the service
    private var closureOnInitialise: ((Box, Any) -> Void)?
    
    /// Initialiser for a permanent store of a registered service.
    /// - Parameter factory: The factory method used to create an instance of the service.
    init(_ factory: @escaping ((Resolver) -> Service)) {
        self.factory = factory
    }
    
    /// This function returns the single stored instance of the service
    /// - Parameter resolver: The resolver object to be used when resolving dependencies
    /// - Returns: A newly created service with each function call.
    func service(_ resolver: Resolver) -> Any {
        if let service = self.service {
            return service
        }
        let newService = factory(resolver)
        self.service = newService
        closureOnInitialise?(resolver, newService)
        return newService
    }
    
    /// call this function to set a closure called immediately after creation of the service.
    func onInitialised(_ closure: @escaping ((Box, Any) -> Void)) {
        closureOnInitialise = closure
    }
}
