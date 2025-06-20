//
//  OrderServiceTests.swift
//  E-commerceTests
//
//  Created by MacBook on 21/06/2025.
//

import XCTest
@testable import E_commerce

final class OrderServiceTest: XCTestCase {

    var mockService: MockOrderService!

    override func setUpWithError() throws {
        mockService = MockOrderService()
        MockOrderService.shared.shouldReturnError = false
    }

    func testCreateOrderSuccess() {
        let expectation = self.expectation(description: "Create order success")

        mockService.createOrder(cartItems: [], customer: dummyCustomer(), discountCode: nil, discountAmount: nil, discountType: "none", currency: "EGP") { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.order.orderNumber, 1001)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testCreateOrderFailure() {
        MockOrderService.shared.shouldReturnError = true
        let expectation = self.expectation(description: "Create order failed")

        mockService.createOrder(cartItems: [], customer: dummyCustomer(), discountCode: nil, discountAmount: nil, discountType: "none", currency: "EGP") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Create order failed")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testGetOrdersSuccess() {
        let expectation = self.expectation(description: "Get orders success")

        mockService.getOrders(forEmail: "test@example.com") { result in
            switch result {
            case .success(let orders):
                XCTAssertEqual(orders.count, 1)
                XCTAssertEqual(orders.first?.name, "Test Order")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testGetOrdersFailure() {
        MockOrderService.shared.shouldReturnError = true
        let expectation = self.expectation(description: "Get orders failure")

        mockService.getOrders(forEmail: "test@example.com") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Get orders failed")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    private func dummyCustomer() -> Customer {
        return Customer(id: 1, email: "test@example.com", firstName: "John", lastName: "Doe", phone: "0100000000", defaultAddress: nil)
    }
}
