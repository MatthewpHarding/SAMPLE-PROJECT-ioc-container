//
//  WeakRefCircularDependencyTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 19/06/2022.
//

import XCTest
@testable import SwincyBox

/*
    💡 Coding Test Scenario
    This is just a reminder about the coding test scenario.
    Client applications may use circular dependencies even though they reflect rather poor architectutral discisions.
    It is not the role of this Framework to prevent them nor encourage them, but rather ´support´them in a mild manner.
 
    At the very least, we can create some unit tests to understand the scenario and situation a little better.
 
 */

// MARK: - Test Models With Circular Dependencies

private class CrashTestDummy {
    var car: SafetyTestCar              // 💡 Coding Test Discussion: A strong reference is safely used here
    
    init (car: SafetyTestCar) {
        self.car = car
    }
}

private class SafetyTestCar {
    weak var driver: CrashTestDummy?    // 💡 Coding Test Discussion: This connection will only exist while an instance of CrashTestDummy is held within the box (or at least 1 other reference but obvisouly that wont be a 'safe' scenario).
    
    init(driver: CrashTestDummy?) {
        self.driver = driver
    }
}

// MARK: - Storage Type Permanent

class WeakRefCircularDependencyTests_permanent: XCTestCase {

    // MARK: - Setup / Tear Down
    
    let box = Box()

    override func setUpWithError() throws {
        
        box.register(SafetyTestCar.self, life: .permanent) { SafetyTestCar(driver: nil) }
        
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

class WeakCircularDependencyTests_transient: XCTestCase {

    // MARK: - Setup / Tear Down
    
    let box = Box()

    override func setUpWithError() throws {
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
    
    func testDriverCircularDependency() {
        
        let driver = box.resolve() as CrashTestDummy
        XCTAssertNotNil(driver.car.driver, "Unexpected value of nil found in circular dependency property driver.car.driver")
    }
    
    func testCarCircularDependency() {
        // As there is no strong refrences to the CrashTestDummy object it will immediately be deallocated from memory as soon as we resolve and recieve the SafetyTestCar object from our box
        let car = box.resolve() as SafetyTestCar
        XCTAssertNil(car.driver?.car, "Expected nil reference in circular dependency property but value found")
    }
    
}