//
//  ResolvingAsProtocolTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox

class ResolvingAsProtocolTests: XCTestCase {

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
    
    func testRecievedVehiclePropertyValues() throws {
        let vehicle = box.resolve() as Vehicle
        XCTAssertTrue(Car.self == type(of: vehicle), "Unexpected type returned from box")
    }
}
