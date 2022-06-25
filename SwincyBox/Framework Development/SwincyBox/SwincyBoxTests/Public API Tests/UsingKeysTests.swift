//
//  UsingKeysTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox

class UsingKeysTests: XCTestCase {

    // MARK: - Setup / Tear Down
    
    private let box = Box()

    override func setUpWithError() throws {
        box.register(key: "sportEngine") { Engine(make: "BMW", model: "Sport 5000", gears: 7) as Transmission }
        box.register(key: "sportsCar") { r in
            return Car(make: "BMW", model: "i8 Roadster Donington Grey", topSpeed: 120, doors: 2, imageName: "BMW-Roadster", engine: r.resolve(key: "sportEngine")) as Vehicle
        }
        box.register(key: "stableEngine") {
            return Engine(make: "VW", model: "White-Label Engine v5.0", gears: 6) as Transmission
        }
        box.register(key: "familyCar") { r in
            return Car(make: "BMW", model: "X3", topSpeed: 90, doors: 5, imageName: "BMW-X3", engine: r.resolve(key: "stableEngine")) as Vehicle
        }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }

    // MARK: - Unit Tests
    
    func testThatVehicleInstancesAreDifferent() throws {
        let sportsVehicle = box.resolve(key: "sportsCar") as Vehicle
        let familyVehicle = box.resolve(key: "familyCar") as Vehicle
        guard let sportsCar = sportsVehicle as? Car,
            let familyCar = familyVehicle as? Car else {
            XCTAssert(false, "Could not typecast Vehicle to concrete class Car")
            return
        }
        XCTAssertTrue(sportsCar !== familyCar, "Resolved values are the same instance")
    }
}
