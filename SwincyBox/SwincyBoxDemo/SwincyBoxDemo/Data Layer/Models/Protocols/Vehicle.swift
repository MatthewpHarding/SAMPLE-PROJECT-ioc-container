//
//  Vehicle.swift
//  SwincyDemo
//
//  Created by Matthew Paul Harding on 18/06/2022.
//

import Foundation

protocol Vehicle {
    var make: String { get }
    var model: String { get }
    var topSpeed: Int { get }
    var doors: Int { get }
    
    var imageName: String { get }
    
    var engine: Transmission { get }
}
