//
//  BasicTests_Permanent.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox

class BasicTests_Permanent: XCTestCase {

    // MARK: - Setup / Tear Down
    
    private let box = Box()

    override func setUpWithError() throws {
        
        box.register(life: .permanent) { Engine(make: "BMW", model: "Sport 5000", gears: 7) as Transmission }
        
        box.register(life: .permanent) { r in
            return Car(make: "BMW", model: "i8 Roadster Donington Grey", topSpeed: 120, doors: 2, imageName: "BMW-Roadster", engine: r.resolve()) as Vehicle
        }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }

    // MARK: - Unit Tests
    
    func testRecievedVehiclePropertyValues() throws {
        
        let vehicle = box.resolve() as Vehicle
        
        XCTAssertTrue("BMW" == vehicle.make, "Unexpected value from boxed protocol")
        XCTAssertTrue("i8 Roadster Donington Grey" == vehicle.model, "Unexpected value from boxed protocol")
        XCTAssertTrue(120 == vehicle.topSpeed, "Unexpected value from boxed protocol")
        XCTAssertTrue(2 == vehicle.doors, "Unexpected value from boxed protocol")
    }
    
    func testRecievedEnginePropertyValues() throws {
        
        let vehicle = box.resolve() as Vehicle
        let transmission = vehicle.engine
        
        XCTAssertTrue("BMW" == transmission.make, "Unexpected value from boxed protocol")
        XCTAssertTrue("Sport 5000" == transmission.model, "Unexpected value from boxed protocol")
        XCTAssertTrue(7 == transmission.gears, "Unexpected value from boxed protocol")
    }
    
    func testRecievedVehicleType() throws {
        
        let vehicle = box.resolve() as Vehicle
        
        XCTAssertTrue(Car.self == type(of:vehicle), "Unexpected type returned from box")
    }
    
    func testRecievedEngineType() throws {
        
        let vehicle = box.resolve() as Vehicle
        let transmission = vehicle.engine
        
        XCTAssertTrue(Engine.self == type(of: transmission), "Unexpected type returned from box")
    }
}
