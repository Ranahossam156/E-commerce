//
//  OrderServiceTest.swift
//  E-commerceTests
//

import XCTest
@testable import E_commerce

final class OrderServiceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        OrderServiceMock.shouldReturnError = false
        OrderServiceMock.mockCreateOrderResponse = nil
        OrderServiceMock.mockGetOrdersResponse = nil
    }

    func testCreateOrder_Success() {
        let dummyOrder = OrderModel(
            id: 1001,
            adminGraphqlAPIID: "gid://shopify/Order/1001",
            orderNumber: 1234,
            name: "Order #1234",
            createdAt: Date(),
            processedAt: Date(),
            financialStatus: .paid,
            currency: .egp,
            totalPrice: "100.00",
            totalDiscounts: "10.00",
            subtotalPrice: "90.00",
            email: "john@example.com",
            contactEmail: "john@example.com",
            confirmationNumber: "CONF1234",
            confirmed: true,
            lineItems: [],
            customer: Customer(id: 1, email: "john@example.com", firstName: "John", lastName: "Doe", phone: "0100000000", defaultAddress: nil),
            shippingAddress: nil,
            billingAddress: nil,
            discountApplications: [],
            fulfillments: [],
            shippingLines: [],
            refunds: []
        )
        
        OrderServiceMock.mockCreateOrderResponse = OrderResponse(order: dummyOrder)

        let expectation = self.expectation(description: "Order created successfully")

        let service = OrderServiceMock()
        service.createOrder(cartItems: [], customer: dummyOrder.customer!, discountCode: nil, discountAmount: nil, discountType: "percentage", currency: "EGP") { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.order.id, dummyOrder.id)
                XCTAssertEqual(response.order.totalPrice, dummyOrder.totalPrice)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testCreateOrder_Failure() {
        OrderServiceMock.shouldReturnError = true
        let expectation = self.expectation(description: "Order creation should fail")

        let dummyCustomer = Customer(id: 1, email: "john@example.com", firstName: "John", lastName: "Doe", phone: nil, defaultAddress: nil)

        let service = OrderServiceMock()
        service.createOrder(cartItems: [], customer: dummyCustomer, discountCode: nil, discountAmount: nil, discountType: "percentage", currency: "EGP") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure:
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testGetOrders_Success() {
        let dummyOrder = OrderModel(
            id: 2002,
            adminGraphqlAPIID: nil,
            orderNumber: 5678,
            name: "Order #5678",
            createdAt: Date(),
            processedAt: Date(),
            financialStatus: .paid,
            currency: .egp,
            totalPrice: "200.00",
            totalDiscounts: "0.00",
            subtotalPrice: "200.00",
            email: "test@example.com",
            contactEmail: "test@example.com",
            confirmationNumber: nil,
            confirmed: true,
            lineItems: [],
            customer: nil,
            shippingAddress: nil,
            billingAddress: nil,
            discountApplications: [],
            fulfillments: [],
            shippingLines: [],
            refunds: []
        )

        OrderServiceMock.mockGetOrdersResponse = [dummyOrder]

        let expectation = self.expectation(description: "Fetched orders")

        let service = OrderServiceMock()
        service.getOrders(forEmail: "test@example.com") { result in
            switch result {
            case .success(let orders):
                XCTAssertEqual(orders.count, 1)
                XCTAssertEqual(orders.first?.id, dummyOrder.id)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testGetOrders_Failure() {
        OrderServiceMock.shouldReturnError = true

        let expectation = self.expectation(description: "Fetching orders should fail")

        let service = OrderServiceMock()
        service.getOrders(forEmail: "test@example.com") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure:
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
