import XCTest
@testable import E_commerce

final class BrandServiceTest: XCTestCase {
    
    var mockService: MockBrandService.Type!

    override func setUpWithError() throws {
        mockService = MockBrandService.self
        MockBrandService.shared.shouldReturnError = false
    }

    func testFetchBrandsSuccess() {
        let expectation = self.expectation(description: "Fetch mock brands success")

        mockService.fetchDataFromAPI { res, err in
            XCTAssertNil(err)
            XCTAssertEqual(res?.smartCollections?.count, 1)
            XCTAssertEqual(res?.smartCollections?.first?.title, "Mock Brand")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchBrandsFailure() {
        MockBrandService.shared.shouldReturnError = true
        let expectation = self.expectation(description: "Fetch mock brands failure")

        mockService.fetchDataFromAPI { res, err in
            XCTAssertNotNil(err)
            XCTAssertNil(res)
            XCTAssertEqual(err?.localizedDescription, "Mock error")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
