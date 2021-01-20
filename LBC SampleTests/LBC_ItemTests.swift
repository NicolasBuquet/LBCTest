//
//  LBC_ItemTests.swift
//  LBC SampleTests
//
//  Created by Nicolas Buquet on 18/01/2021.
//

import XCTest
@testable import LBC_Sample

class LBC_ItemTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testItemsLoadingAndParsing() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        print("Unit test: Item Loading and Parsing started")
        
        let url = Bundle(for: LBC_ItemTests.self).url(forResource: "TestsItems", withExtension: "json")!
        let itemsData = try Data(contentsOf: url)
        let items = Item.parse(from: itemsData)
        XCTAssert(items?.count == 300, "testItemsLoadingAndParsing: failure to load Json")
        
        print("Unit test: Item Loading and Parsing ended")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
