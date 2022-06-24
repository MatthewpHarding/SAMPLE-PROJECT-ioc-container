//
//  AppLaunchTests.swift
//  AppLaunchTests
//
//  Created by Matthew Paul Harding on 18/06/2022.
//

import XCTest
@testable import SwincyBoxDemo

class AppLaunchTests: XCTestCase {

    func testSwincyBoxConfig() throws {
        let app = App.shared
        XCTAssertNotNil(app.bmwShowroom, "BMW Showroom has not been properly registered within the SwincyBox Framework")
        XCTAssertNotNil(app.mercederShowroom, "Mercedes Showroom has not been properly registered within the SwincyBox Framework")
    }

}


