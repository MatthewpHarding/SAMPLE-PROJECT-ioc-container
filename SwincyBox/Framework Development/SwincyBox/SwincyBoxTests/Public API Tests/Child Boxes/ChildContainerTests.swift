//
//  ChildContainerTests.swift
//  SwincyBoxTests
//
//  Created by Matthew Paul Harding on 23/06/2022.
//

import XCTest
import SwincyBox

class ChildContainerTests: XCTestCase {

    let rootBox = Box()
    var bmwBox: Box!
    var mercedesBox: Box!
    
    override func setUpWithError() throws {
        /*
            Scenario: Both manufacturers use the same engine manufacturer, Volkswagen.
         
            Root box contains: shared assets
            BMW box contains: specific BMW showroom with BMW cars
            Mercedes box contains: specific Mercedes showroom with Mercedes cars
         
            We will then have:
                1 ViewController for BMW,       communicating with the BMW box
                1 ViewController for Mercedes,  communicating with the Mercedes box
         
         
                ROOT
              --------              The root box is used for a shared 'Engine' resource
              |  VW  |
              |engine|
              --------
              |      |
          CHILD      CHILD
         --------   --------        Each child box registers a different 'Showroom'
         | BMW  |   | MERC |        based on manufacturer
         |  A   |   |  B   |
         --------   --------
         Showroom   Showroom
         
         Usage:
                a) Root Box will NOT contain a Showroom service
                b) Child box A (BMW) WILL contain a Showroom service
                c) Child box B (MERC) WILL contain a Showroom service
         
         */
        rootBox.register() {
            // 📦 We can register this Engine as the 'Transmission' protocol resulting in ALL Transmission dependencies becoming VW Engine Models
            return Engine(make: "VW", model: "White-Label Engine v5.0", gears: 6) as Transmission
        }
        bmwBox = rootBox.addChildBox(forKey: "bmwBox")
        setUpBMWCars(withChildBox: bmwBox)
        mercedesBox = rootBox.addChildBox(forKey: "mercedesBox")
        setUpMercedesCars(withChildBox: mercedesBox)
    }
    
    func setUpBMWCars(withChildBox box: Box) {
        box.register(key: "sportsCar") { r in
            return Car(make: "BMW", model: "i8 Roadster Donington Grey", topSpeed: 120, doors: 2, imageName: "BMW-Roadster", engine: r.resolve()) as Vehicle
        }
        box.register(key: "familyCar") { r in
            return Car(make: "BMW", model: "X3", topSpeed: 90, doors: 5, imageName: "BMW-X3", engine: r.resolve()) as Vehicle
        }
        box.register() { r in
            return Showroom(familyCar: r.resolve(key: "familyCar"), sportsCar: r.resolve(key: "sportsCar"), manufacturer: "BMW") as Showroom
        }
    }
    
    func setUpMercedesCars(withChildBox box: Box) {
        box.register(key: "sportsCar") { r in
            return Car(make: "Mercedes", model: "AMG GT Coupé", topSpeed: 160, doors: 3, imageName: "SportsCar", engine: r.resolve()) as Vehicle
        }
        box.register(key: "familyCar") { r in
            return Car(make: "Mercedes", model: "C-Class Sedan", topSpeed: 100, doors: 5, imageName: "FamilyCar", engine: r.resolve()) as Vehicle
        }
        box.register() { r in
            return Showroom(familyCar: r.resolve(key: "familyCar"), sportsCar: r.resolve(key: "sportsCar"), manufacturer: "Mercedes") as Showroom
        }
    }

    override func tearDownWithError() throws {
        rootBox.clear()
    }
    
    // MARK: - BMW Showroom Tests
    
    func testThatBMWUseVWEngines() throws {
        let box: Box = bmwBox
        let showroom = box.resolve() as Showroom
        let familyCar = showroom.familyCar
        let sportsCar = showroom.sportsCar
        XCTAssertTrue("BMW" == familyCar.make, "Unexpected make of car")
        XCTAssertTrue("BMW" == sportsCar.make, "Unexpected make of car")
        XCTAssertTrue("VW" == familyCar.engine.make, "Unexpected make of engine")
        XCTAssertTrue("VW" == sportsCar.engine.make, "Unexpected make of engine")
    }
    
    func testThatBMWShowroomContainsBMWCars() throws {
        let box: Box = bmwBox
        let showroom = box.resolve() as Showroom
        let familyCar = showroom.familyCar
        let sportsCar = showroom.sportsCar
        XCTAssertTrue("BMW" == familyCar.make, "Unexpected make of car")
        XCTAssertTrue("BMW" == sportsCar.make, "Unexpected make of car")
    }
    
    // MARK: - Mercedes Showroom Tests
    
    func testThatMercedesUseVWEngines() throws {
        let box: Box = mercedesBox
        let showroom = box.resolve() as Showroom
        let familyCar = showroom.familyCar
        let sportsCar = showroom.sportsCar
        XCTAssertTrue("Mercedes" == familyCar.make, "Unexpected make of car")
        XCTAssertTrue("Mercedes" == sportsCar.make, "Unexpected make of car")
        XCTAssertTrue("VW" == familyCar.engine.make, "Unexpected make of engine")
        XCTAssertTrue("VW" == sportsCar.engine.make, "Unexpected make of engine")
    }
    
    func testThatMercedesShowroomContainsMercedesCars() throws {
        let box: Box = mercedesBox
        let showroom = box.resolve() as Showroom
        let familyCar = showroom.familyCar
        let sportsCar = showroom.sportsCar
        XCTAssertTrue("Mercedes" == familyCar.make, "Unexpected make of car")
        XCTAssertTrue("Mercedes" == sportsCar.make, "Unexpected make of car")
    }
}
