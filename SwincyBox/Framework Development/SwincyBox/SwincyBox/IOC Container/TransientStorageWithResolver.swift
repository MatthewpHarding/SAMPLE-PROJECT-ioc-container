//
//  TransientStorageWithResolver.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 20/06/2022.
//

import Foundation

final class TransientStorageWithResolver<T>: ServiceStorage {
    
    private let factory: ((Box) -> T)
    
    func constructService(_ resolver: Box) -> T {
        return factory(resolver)
    }

    init(_ factory: @escaping ((Box) -> T)) {
        self.factory = factory
    }
}
