//
//  DifferentInstanceTests_Permenant.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox

class DifferentInstanceTests_Permenant: XCTestCase {
    // MARK: - Setup / Tear Down
    private let box = Box()

    override func setUpWithError() throws {
        box.register(life: .permanent) { Engine(make: "BMW", model: "Sport 5000", gears: 7) as Engine }
        box.register(life: .permanent) { r in
            return Car(make: "BMW", model: "i8 Roadster Donington Grey", topSpeed: 120, doors: 2, imageName: "BMW-Roadster", engine: r.resolve() as Engine) as Car
        }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }

    // MARK: - Unit Tests
    func testThatCarInstancesAreDifferent() throws {
        let car = box.resolve() as Car
        let car2 = box.resolve() as Car
        XCTAssertTrue(car === car2, "Resolved values are not the same instance")
    }
    
    func testThatEngineInstancesAreDifferent() throws {
        let engine = box.resolve() as Engine
        let engine2 = box.resolve() as Engine
        XCTAssertTrue(engine === engine2, "Resolved values are not the same instance")
    }
}
