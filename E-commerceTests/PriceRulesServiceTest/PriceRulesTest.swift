//  PriceRuleNetworkServiceTests.swift
//  E-commerceTests
//
//  Created by Kerolos on 02/06/2025.
//

import XCTest
@testable import E_commerce

class PriceRuleNetworkServiceTests: XCTestCase {
    
    func testFetchPriceRulesFromRealAPI() {
        let expectation = XCTestExpectation(description: "API call completes")
        
        PriceRuleNetworkService.fetchDataFromAPI { response, error in
            XCTAssertTrue(response?.priceRules.first?.title == "Summer Sale")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchDiscountCodesFromRealAPI() {
        let expectation = XCTestExpectation(description: "API call completes")
        
        PriceRuleNetworkService.fetchDiscountCodes(for: 1489809670441) { codes, error in
            XCTAssertTrue(codes?.count == 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    

    
    func testFetchDiscountCodesWithNetworkError() {
        let expectation = XCTestExpectation(description: "Network error API call fails")
        let invalidPriceRuleId = 999999999 
        
        PriceRuleNetworkService.fetchDiscountCodes(for: invalidPriceRuleId) { codes, error in
            XCTAssertNil(codes, "Codes should be nil for network error")
            XCTAssertNotNil(error, "Error should not be nil for network error")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
