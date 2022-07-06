//
//  StorageType.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation

/// LifeType represents the two states of dependency registration for class instances (reference types) such as, registering a creation factory or instantiating just one single instance. The transient type will register a factory generating new instances with each method call. The permanent type will create a single instance storing it immediately within memory for all future use. These two options do not apply to value types such as structs, which will always return copied data due to the nature of value types and areas of memory.
public enum LifeType {
    case transient
    case permanent
}
