import XCTest
@testable import E_commerce

class PriceRuleNetworkServiceTests: XCTestCase {
    
    func testFetchPriceRulesFromRealAPI() {
        // Create expectation
        let expectation = XCTestExpectation(description: "API call completes")
        
        // Call the method
        PriceRuleNetworkService.fetchDataFromAPI { response, error in
            // Check we got something back
            XCTAssertTrue(response != nil || error != nil, "Should get either response or error")
            expectation.fulfill()
        }
        
        // Wait for API call to complete
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchDiscountCodesFromRealAPI() {
        // Create expectation
        let expectation = XCTestExpectation(description: "API call completes")
        
        // Call the method with a price rule ID
        PriceRuleNetworkService.fetchDiscountCodes(for: 123456) { codes, error in
            // Check we got something back
            XCTAssertTrue(codes != nil || error != nil, "Should get either codes or error")
            expectation.fulfill()
        }
        
        // Wait for API call to complete
        wait(for: [expectation], timeout: 10.0)
    }
}
