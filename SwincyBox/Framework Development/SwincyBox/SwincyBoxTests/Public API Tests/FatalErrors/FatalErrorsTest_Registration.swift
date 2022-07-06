//
//  CircularDependencyTests.swift
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
    var car: SafetyTestCar          // 💡 Coding Test Discussion: Retain cycles exist in this scenario.
    
    init (car: SafetyTestCar) {
        self.car = car
    }
}

private class SafetyTestCar {
    var driver: CrashTestDummy?     // 💡 Coding Test Discussion: This is essentially the issue with circular refrences. This will of course create a retain cycle between SafetyTestCar and CrashTestDummy. Both won't be removed from memory and thus the client of the SwincyBox framework should re-think their core architecture. This has been included within the test as a valid use-case scenario within client apps and how they use this framework.
    
    init(driver: CrashTestDummy?) {
        self.driver = driver
    }
}

class FatalErrorsTest_Registration: XCTestCase {

    // MARK: - Setup / Tear Down
    
    let box = Box()
    
    // MARK: - Unit Tests
    
    /*
    func testThatWeHaventRegisteredDependency() {
        do {
            let car = box.resolve() as SafetyTestCar
            XCTFail("Failed to throw a fatalError() when resolving an unregistered type")
        }
        catch {
            
        }
    }
     */
}
