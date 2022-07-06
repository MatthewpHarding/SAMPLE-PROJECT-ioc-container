//
//  ResolvingError.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 06/07/2022.
//

import Foundation

/// The error type thrown when uncovering errors during the resolving proccess
enum ResolvingError: Error {
    case unregisteredType(key: String)
    case typeMismatch(key: String)
    case infinateRecurrsionDetected(stack: [String])
}

/// An extension to return a more detailed explanation of the error thrown
extension ResolvingError {
    var description: String {
        switch self {
        case .unregisteredType (let key): return "Dependency not registered for service key: \(key)"
        case .typeMismatch (let key): return "Stored service returned unexpected type for service key: \(key)"
        case .infinateRecurrsionDetected (let stack): return "Infinate loop detected for resolving dependencies for resolution stack: \(stack)"
        }
    }
}
