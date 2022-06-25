//
//  Showroom.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import Foundation


// MARK: - Enum
enum ShowroomShopWindow {
    case familyDriving
    case funMiddleAgedDriving
}

// MARK: - Showroom Declaration
/*
    NOTE: 📦
    We use Classes for Showroom, Car and Engine to demonstrate
    using instances within the SwincyBox framework
 */
class Showroom {
    var manufacturer: String
    var familyCar: Vehicle
    var sportsCar: Vehicle
    var shopWindowType: ShowroomShopWindow = .familyDriving
    
    init(familyCar: Vehicle, sportsCar: Vehicle, manufacturer: String) {
        self.familyCar = familyCar
        self.sportsCar = sportsCar
        self.manufacturer = manufacturer
    }
}

// MARK: - Shop Window
extension Showroom {
    var shopWindowVehicle: Vehicle {
        get {
            switch shopWindowType {
            case .funMiddleAgedDriving: return sportsCar
            case .familyDriving: return familyCar
            }
        }
    }
}
