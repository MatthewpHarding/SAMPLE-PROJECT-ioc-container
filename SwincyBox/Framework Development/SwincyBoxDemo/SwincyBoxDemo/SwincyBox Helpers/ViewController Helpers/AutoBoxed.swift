//
//  AutoBoxed.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation
import UIKit

// 📦 You can auto inject dependencies into UIViewControllers simply by using this propertyWrapper.
//    Syntax example: @AutoBoxed var showroom: Showroom?
@propertyWrapper
struct AutoBoxed<T> {
    private var service: T?
    
    var wrappedValue: T {
        mutating get {
            if service == nil {
                service = App.shared.box.resolve(T.self)
            }
            return service!
        }
        set { service = newValue }
    }
}
