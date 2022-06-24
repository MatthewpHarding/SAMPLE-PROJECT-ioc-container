//
//  Engine.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 24/06/2022.
//

import Foundation

/*
    NOTE: 📦
    We use Classes for Showroom, Car and Engine to demonstrate
    using instances within the SwincyBox framework
 */
class Engine: Transmission {
    let make: String
    let model: String
    let gears: Int
    
    init(make: String, model: String, gears: Int) {
        self.make = make
        self.model = model
        self.gears = gears
    }
}
