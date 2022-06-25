//
//  SharedBox.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 20/06/2022.
//

import Foundation
import SwincyBox

// MARK: - Register Dependencies
extension App {
    func registerRootDependencies() {
        // BMW and Mercedes both use Volkswagen engines
        // Q: How can we cleverly handle this?
        box.register() {
            // 📦 We can register this Engine as the 'Transmission' protocol resulting in ALL Transmission dependencies becoming VW Engine Models
            return Engine(make: "VW", model: "White-Label Engine v5.0", gears: 6) as Transmission
        }
        /*
         BMW and Mercedes register different vehicles, however in this example app
         BOTH brands create their vehicles using Volkswagen engines
         and so we use:
            1. The root Box to register shared dependencies such as Volkswagen engines
            2. A childBox for a BMW Showroom
            3. A childbox for a Mercedes Showroom
         
         
                ROOT
              --------              The root box is used for a shared 'Engine' resource
              |  VW  |
              |engine|
              --------
              |      |
          CHILD      CHILD
         --------   --------        Each child box registers a different 'Showroom'
         | BMW  |   | MERC |        based on manufacturer i.e. BMW & Mercedes
         |  A   |   |  B   |
         --------   --------
         Showroom   Showroom
         
         Usage:
                a) Root Box,    will NOT contain a Showroom service
                b) Child box A, (BMW) WILL contain a Showroom service
                c) Child box B, (MERC) WILL contain a Showroom service
         
         */
        
        // BMW Box contains BMW Showroom + BMW Cars
        let bmwBox = box.addChildBox(forKey: Keys.Box.bmwBox)
        setUpBMWCars(withChildBox: bmwBox)
        
        // MERC Box contains MERC Showroom + MERC Cars
        let mercBox = box.addChildBox(forKey: Keys.Box.mercedesBox)
        setUpMercedesCars(withChildBox: mercBox)
    }
}

// MARK: - Register Dependencies - BMW
extension App {
    private func setUpBMWCars(withChildBox box: Box) {
        // →    The BMW sportsCar is a special case!
        //      It's the only car to use a custom Engine!
        box.register(key: Keys.Box.sportEngine) { Engine(make: "BMW", model: "Sport 5000", gears: 7) as Transmission }
        box.register(key: Keys.Box.sportsCar) { r in
            return Car(make: "BMW", model: "i8 Roadster Donington Grey", topSpeed: 120, doors: 2, imageName: "BMW-Roadster", engine: r.resolve(key: Keys.Box.sportEngine)) as Vehicle
        }
        box.register(key: Keys.Box.familyCar) { r in
            return Car(make: "BMW", model: "X3", topSpeed: 90, doors: 5, imageName: "BMW-X3", engine: r.resolve()) as Vehicle
        }
        box.register() { r in
            return Showroom(familyCar: r.resolve(key: Keys.Box.familyCar), sportsCar: r.resolve(key: Keys.Box.sportsCar), manufacturer: "BMW") as Showroom
        }
    }
}

// MARK: - Register Dependencies - Mercedes
extension App {
    private func setUpMercedesCars(withChildBox box: Box) {
        box.register(key: Keys.Box.sportsCar) { r in
            return Car(make: "Mercedes", model: "AMG GT Coupé", topSpeed: 160, doors: 3, imageName: "Merc-AMG", engine: r.resolve()) as Vehicle
        }
        box.register(key: Keys.Box.familyCar) { r in
            return Car(make: "Mercedes", model: "C-Class Sedan", topSpeed: 100, doors: 5, imageName: "Merc-C-Class", engine: r.resolve()) as Vehicle
        }
        box.register() { r in
            return Showroom(familyCar: r.resolve(key: Keys.Box.familyCar), sportsCar: r.resolve(key: Keys.Box.sportsCar), manufacturer: "Mercedes") as Showroom
        }
    }
}
