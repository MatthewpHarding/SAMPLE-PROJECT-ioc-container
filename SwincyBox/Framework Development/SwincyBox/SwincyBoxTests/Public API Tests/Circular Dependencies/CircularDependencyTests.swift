//
//  CircularDependencyTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox


/*
    💡 Circular Dependency Scenario
    
    Client applications may use circular dependencies even though they reflect rather poor architectutral discisions.
    It is not the role of this Framework to prevent them nor encourage them, but rather ´support´them in a mild manner.
 
    At the very least, we can create some unit tests to understand the scenario and situation a little better.
 */

// MARK: - Test Models With Circular Dependencies

private class CrashTestDummy {
    var car: SafetyTestCar          // 💡 Retain cycles will exist here, as both properties use strong references
 
    init (car: SafetyTestCar) {
        self.car = car
    }
}

private class SafetyTestCar {
    var driver: CrashTestDummy?     // 💡 Discussion: This is essentially the issue with circular refrences. This will of course create a retain cycle between SafetyTestCar and CrashTestDummy. Both won't be removed from memory and thus the client of the SwincyBox framework should re-think their core architecture. This has been included as test for a valid use-case scenario within client apps and how they may use this framework.
    
    init(driver: CrashTestDummy?) {
        self.driver = driver
    }
}

// MARK: - Storage Type Permanent

class CircularDependencyTests_permanent: XCTestCase {

    // MARK: - Setup / Tear Down
    
    let box = Box()

    override func setUpWithError() throws {
        // NOTE: We MUST understand that we have created a retain cycle in ARC by using strong circular references
        //       Weak references would simply be deallocated immediately and so exists a memory issue
        box.register(life: .permanent) { SafetyTestCar(driver: nil) }
        box.register(CrashTestDummy.self, life: .permanent) { resolver in
            let driver = CrashTestDummy(car: resolver.resolve())
            let car = driver.car
            car.driver = driver
            return driver
        }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }
    
    // MARK: - Unit Tests
    
    func testDriverCircularDependency() {
        let driver = box.resolve() as CrashTestDummy
        XCTAssertNotNil(driver.car.driver, "Unexpected value of nil found in circular dependency property driver.car.driver")
    }
    
    func testCarCircularDependency() {
        let car = box.resolve() as SafetyTestCar
        XCTAssertNotNil(car.driver?.car, "Unexpected value of nil found in circular dependency property car.driver.car")
    }
    
}

// MARK: - Storage Type Transient

class CircularDependencyTests_transient: XCTestCase {

    // MARK: - Setup / Tear Down
    
    let box = Box()

    override func setUpWithError() throws {
        // NOTE: We MUST understand that we have created a retain cycle in ARC by using strong circular references
        //       Weak references would simply be deallocated immediately and so exists a memory issue
        box.register(CrashTestDummy.self, life: .transient) {
            let driver = CrashTestDummy(car: SafetyTestCar(driver: nil))
            let car = driver.car
            car.driver = driver
            return driver
        }
        
        box.register(SafetyTestCar.self, life: .transient) {
            let driver = CrashTestDummy(car: SafetyTestCar(driver: nil))
            let car = driver.car
            car.driver = driver
            return car
        }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }
    
    // MARK: - Unit Tests
    
    func testThatDriverCircularDependencyExists() {
        let driver = box.resolve() as CrashTestDummy
        XCTAssertNotNil(driver.car.driver, "Unexpected value of nil found in circular dependency property driver.car.driver")
    }
    
    func testThatCarCircularDependencyExists() {
        let car = box.resolve() as SafetyTestCar
        XCTAssertNotNil(car.driver?.car, "Unexpected value of nil found in circular dependency property car.driver.car")
    }    
}
