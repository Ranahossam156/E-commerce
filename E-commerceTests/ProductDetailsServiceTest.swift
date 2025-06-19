//
//  ProductDetailsServiceTest.swift
//  E-commerceTests
//
//  Created by Macos on 18/06/2025.
//
import Foundation
import Alamofire
import XCTest
@testable import E_commerce
final class ProductDetailsServiceTest: XCTestCase {
    override func setUp() {
        super.setUp()
        ProductDetailsServiceMock.shouldReturnError = false
        ProductDetailsServiceMock.mockProductResponse = nil
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFetchProductDetails_Success() {
        let mockProduct = Product(
            id: 123,
            title: "Test Product",
            bodyHTML: "Test description",
            vendor: "Test Vendor",
            productType: "Test Type",
            createdAt: "2025-06-18T10:00:00Z",
            handle: "test-product",
            updatedAt: "2025-06-18T11:00:00Z",
            publishedAt: "2025-06-18T09:00:00Z",
            templateSuffix: nil,
            publishedScope: "web",
            tags: "test, product",
            status: "active",
            adminGraphqlAPIID: "gid://shopify/Product/123",
            variants: [],
            options: [],
            images: [],
            image: ProductImage(id: 1, alt: "Main Image", position: 1, productID: 123, createdAt: "", updatedAt: "", adminGraphqlAPIID: "", width: 100, height: 100, src: "https://example.com/image.jpg", variantIDs: [])
        )
        ProductDetailsServiceMock.mockProductResponse = SingleProductResponse(product: mockProduct)

        let expectation = self.expectation(description: "Product details fetched successfully")

        ProductDetailsServiceMock.fetchProductDetails(productID: 123) { response in
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.product.id, mockProduct.id)
            XCTAssertEqual(response?.product.title, mockProduct.title)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testFetchProductDetails_Failure() {
        ProductDetailsServiceMock.shouldReturnError = true

        let expectation = self.expectation(description: "Product details fetch failed")

        ProductDetailsServiceMock.fetchProductDetails(productID: 456) { response in
            XCTAssertNil(response)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testNetworkService_fetchProductDetails_RealAPI() {
        let expectation = self.expectation(description: "Real product details fetched")

        ProductDetailsService.fetchProductDetails(productID: 9712148775209) { response in
            XCTAssertNotNil(response, "Expected real response from API")
            XCTAssertEqual(response?.product.id, 9712148775209)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
