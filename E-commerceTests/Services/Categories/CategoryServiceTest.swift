//
//  CategoryServiceTests.swift
//  E-commerceTests
//
//  Created by MacBook on 21/06/2025.
//

import XCTest
@testable import E_commerce

final class CategoryServiceTest: XCTestCase {

    var mockService: MockCategoryService.Type!

    override func setUpWithError() throws {
        mockService = MockCategoryService.self
        MockCategoryService.shared.shouldReturnError = false
    }

    func testFetchCategoriesSuccess() {
        let expectation = self.expectation(description: "Fetch mock categories success")

        mockService.fetchDataFromAPI { res, err in
            XCTAssertNil(err)
            XCTAssertEqual(res?.customCollections?.count, 1)
            XCTAssertEqual(res?.customCollections?.first?.title, "Mock Category")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchCategoriesFailure() {
        MockCategoryService.shared.shouldReturnError = true

        let expectation = self.expectation(description: "Fetch mock categories failure")

        mockService.fetchDataFromAPI { res, err in
            XCTAssertNil(res)
            XCTAssertNotNil(err)
            XCTAssertEqual(err?.localizedDescription, "Mock category error")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
