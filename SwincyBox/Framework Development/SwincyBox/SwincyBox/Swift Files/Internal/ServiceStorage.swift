//
//  Services.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 17/06/2022.
//

import Foundation

// MARK: - Protocol
/// This protocol declares an interface to retrieve a registered service from a storage wrapper, which either generates, instantiates or provides single access to the service it encapsulates or generates. A method is simply called to return the associated service. How the service is stored or instantiated is of no importance here.
public protocol ServiceStoring {
    /// Interface for retrieving an instance of the service stored
    /// - Returns: An instance of the service stored
    func service(_ resolver: Resolver) -> Any
    
    /// An setter to store the callback method called immediately after instantiation of each service created.
    func onInitialised(_ closure: @escaping ((_ resolver: Resolver, _ service: Any) -> Void))
}
