//
//  TransientStorage.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation

final class TransientStorage<T>: ServiceStorage {
    
    private let factory: (() -> T)
    
    func constructService() -> T {
        return factory()
    }

    init(_ factory: @escaping (() -> T)) {
        self.factory = factory
    }
}
