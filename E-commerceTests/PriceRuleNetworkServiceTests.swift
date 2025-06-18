// PriceRuleNetworkServiceTests.swift
import XCTest
@testable import E_commerce

class PriceRuleNetworkServiceTests: XCTestCase {
    
    // Mock response data
    let mockPriceRulesJSON = """
    {
        "price_rules": [
            {
                "id": 1489809670441,
                "value_type": "percentage",
                "value": "-20.0"
            }
        ]
    }
    """.data(using: .utf8)!
    
    let mockDiscountCodesJSON = """
    {
        "discount_codes": [
            {
                "id": 1,
                "code": "TESTCODE"
            }
        ]
    }
    """.data(using: .utf8)!
    
    // Test fetchDataFromAPI success
    func testFetchDataFromAPI_Success() {
        let expectation = XCTestExpectation(description: "Fetch data from API success")
        
        // Arrange and Act
        let decoder = JSONDecoder()
        if let response = try? decoder.decode(PriceRulesResponse.self, from: self.mockPriceRulesJSON) {
            PriceRuleNetworkService.fetchDataFromAPI { fetchedResponse, error in
                // Assert
                XCTAssertNil(error, "No error should occur")
                XCTAssertNotNil(fetchedResponse, "Response should not be nil")
                if let firstRule = fetchedResponse?.priceRules.first {
                    XCTAssertEqual(firstRule.id, 1489809670441, "First rule ID should match")
                } else {
                    XCTFail("No price rules returned")
                }
                expectation.fulfill()
            }
            // Manually trigger the completion with mock data
           // PriceRuleNetworkService.fetchDataFromAPI { _, _ in }(response, nil)
        } else {
            XCTFail("Failed to decode mock response")
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // Test fetchDataFromAPI failure
    func testFetchDataFromAPI_Failure() {
        let expectation = XCTestExpectation(description: "Fetch data from API failure")
        
        // Arrange and Act
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        PriceRuleNetworkService.fetchDataFromAPI { response, fetchedError in
            // Assert
            XCTAssertNil(response, "Response should be nil")
            XCTAssertNotNil(fetchedError, "Error should not be nil")
            if let error = fetchedError as NSError? {
                XCTAssertEqual(error.code, -1, "Error code should match")
            }
            expectation.fulfill()
        }
        // Manually trigger the completion with mock error
       // PriceRuleNetworkService.fetchDataFromAPI { _, _ in }(nil, error)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // Test fetchDiscountCodes success
    func testFetchDiscountCodes_Success() {
        let expectation = XCTestExpectation(description: "Fetch discount codes success")
        let priceRuleId = 123
        
        // Arrange and Act
        let decoder = JSONDecoder()
        if let response = try? decoder.decode(DiscountCodesResponse.self, from: self.mockDiscountCodesJSON) {
            PriceRuleNetworkService.fetchDiscountCodes(for: priceRuleId) { discountCodes, error in
                // Assert
                XCTAssertNil(error, "No error should occur")
                XCTAssertNotNil(discountCodes, "Discount codes should not be nil")
                if let firstCode = discountCodes?.first {
                    XCTAssertEqual(firstCode.id, 1, "First discount code ID should match")
                    XCTAssertEqual(firstCode.code, "TESTCODE", "First discount code should match")
                } else {
                    XCTFail("No discount codes returned")
                }
                expectation.fulfill()
            }
            //            // Manually trigger the completion with mock data
            //            PriceRuleNetworkService.fetchDiscountCodes(for: priceRuleId) { _, _ in }(response.discountCodes, nil)
            //        } else {
            //            XCTFail("Failed to decode mock response")
            //        }
            
            wait(for: [expectation], timeout: 5.0)
        }
        
        // Test fetchDiscountCodes failure
        func testFetchDiscountCodes_Failure() {
            let expectation = XCTestExpectation(description: "Fetch discount codes failure")
            let priceRuleId = 123
            
            // Arrange and Act
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            PriceRuleNetworkService.fetchDiscountCodes(for: priceRuleId) { discountCodes, fetchedError in
                // Assert
                XCTAssertNil(discountCodes, "Discount codes should be nil")
                XCTAssertNotNil(fetchedError, "Error should not be nil")
                if let error = fetchedError as NSError? {
                    XCTAssertEqual(error.code, -1, "Error code should match")
                }
                expectation.fulfill()
            }
            // Manually trigger the completion with mock error
         //   PriceRuleNetworkService.fetchDiscountCodes(for: priceRuleId) { _, _ in }(nil, error)
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    
}
