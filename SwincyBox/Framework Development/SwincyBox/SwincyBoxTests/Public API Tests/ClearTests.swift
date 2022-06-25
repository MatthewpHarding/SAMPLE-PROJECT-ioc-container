//
//  ClearTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox

class ClearTests: XCTestCase {

    // MARK: - Setup / Tear Down
    
    private let box = Box()

    override func setUpWithError() throws {
        box.register() { Engine(make: "BMW", model: "Sport 5000", gears: 7) as Transmission }
        
        box.register() { r in
            return Car(make: "BMW", model: "i8 Roadster Donington Grey", topSpeed: 120, doors: 2, imageName: "BMW-Roadster", engine: r.resolve()) as Vehicle
        }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }

    // MARK: - Unit Tests
    
    func testThatServicesAreRegistered() throws {
        
        XCTAssertTrue(2 == box.registeredServiceCount, "Unexpected number of registered services")
    }
    
    func testClearingAllServices() throws {
        
        box.clear()
        
        XCTAssertTrue(0 == box.registeredServiceCount, "Unexpected number of registered services")
    }
    
}
