//
//  Car.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation

/*
    NOTE: 📦
    We use Classes for Showroom, Car and Engine to demonstrate
    using instances within the SwincyBox framework
 */
class Car: Vehicle {
    let make: String
    let model: String
    let topSpeed: Int
    let doors: Int
    
    let imageName: String
    
    let engine: Transmission
    
    init(make: String, model: String, topSpeed: Int, doors: Int, imageName: String, engine: Transmission) {
        
        self.make = make
        self.model = model
        self.topSpeed = topSpeed
        self.doors = doors
        
        self.imageName = imageName
        
        self.engine = engine
    }
}
