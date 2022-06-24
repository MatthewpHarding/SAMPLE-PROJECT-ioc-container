//
//  PermanentStorage.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation

final class PermanentStorage<T>: ServiceStorage {
    
    var service: T
    
    init(_ service: T) {
        self.service = service
    }
}
