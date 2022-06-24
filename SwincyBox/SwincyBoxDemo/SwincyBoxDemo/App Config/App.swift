//
//  App.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 24/06/2022.
//

import Foundation
import SwincyBox

// MARK: - App Singleton

// 📦 The SwincyBox framework doesn't include singletons. After all, it's up to developers how they want to use SwincyBox. This sample project declares an app singleton to store a root Box for resolving dependencies
class App {
    
    static let shared = App()
    
    let box = Box() // our root box for the app
    static var box: Box {
        return shared.box
    }
}
