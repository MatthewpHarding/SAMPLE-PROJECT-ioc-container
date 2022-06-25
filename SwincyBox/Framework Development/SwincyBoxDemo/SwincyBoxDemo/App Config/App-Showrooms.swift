//
//  App-Showrooms.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 24/06/2022.
//

import Foundation

// MARK: - Resolvable Showrooms
extension App {
    var bmwShowroom: Showroom {
        get {
            guard let bmwBox = box.bmwBox else {
                fatalError("Dependency Failure: Unable to find child box 'BMW'")
            }
            return bmwBox.resolve() as Showroom
        }
    }
    
    var mercederShowroom: Showroom {
        get {
            guard let mercBox = box.mercedesBox else {
                fatalError("Dependency Failure: Unable to find child box 'Mercedes'")
            }
            return mercBox.resolve() as Showroom
        }
    }
}
