//
//  AutoBoxed.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation
import UIKit

// 📦 You can auto inject dependencies into UIViewControllers by using a propertyWrapper. Take a look at ShowroomViewController to see how it's done!
@propertyWrapper
public struct AutoBoxed<T> {
    
    private var service: T?
    
    public init() {}
    
    public var wrappedValue: T {
        mutating get {
            if service == nil {
                service = App.shared.box.resolve(T.self)
            }
            return service!
        }
        set { service = newValue }
    }
    
    public var projectedValue: T {
        return service!
    }
}
