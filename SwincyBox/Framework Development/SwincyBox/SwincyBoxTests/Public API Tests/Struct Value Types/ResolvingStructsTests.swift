//
//  ResolvingStructsTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 20/06/2022.
//

import XCTest
@testable import SwincyBox

class ResolvingStructsTests: XCTestCase {

    // MARK: - Setup / Tear Down
    
    let box = Box()

    override func setUpWithError() throws {
        box.register() { CarHandbook() as CarHandbook }
        box.register() { CarRepairManual() as CarRepairManual }
    }
    
    override func tearDownWithError() throws {
        box.clear()
    }
    
    // MARK: - Unit Tests
    
    func testCarHandbook() {
        let handbook = box.resolve() as CarHandbook
        XCTAssertTrue("Owning A BMW" == handbook.title, "Unexpected value from boxed protocol")
        XCTAssertTrue("Stefan Quandt" == handbook.author, "Unexpected value from boxed protocol")
        XCTAssertTrue(60 == handbook.pages, "Unexpected value from boxed protocol")
    }
    
    func testCarRepairManual() {
        let handbook = box.resolve() as CarRepairManual
        XCTAssertTrue("Repairing A BMW" == handbook.title, "Unexpected value from boxed protocol")
        XCTAssertTrue("Stefan Quandt" == handbook.author, "Unexpected value from boxed protocol")
        XCTAssertTrue(105 == handbook.pages, "Unexpected value from boxed protocol")
    }
}
