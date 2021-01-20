//
//  LBC_CategoryTests.swift
//  LBC SampleTests
//
//  Created by Nicolas Buquet on 20/01/2021.
//

import XCTest
@testable import LBC_Sample

class LBC_CategoryTests: XCTestCase {

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

    func testCategoriesLoadingAndParsing() throws {
        
        print("Unit test: Categories Loading and Parsing started")
        
        let url = Bundle(for: LBC_CategoryTests.self).url(forResource: "TestsCategories", withExtension: "json")!
        let categoriesData = try Data(contentsOf: url)
        let categories = ItemCategory.parse(from: categoriesData)
        XCTAssert(categories?.count == 11, "CategoriesLoadingAndParsing: failure to load Json")
        
        print("Unit test: Categories Loading and Parsing ended")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
