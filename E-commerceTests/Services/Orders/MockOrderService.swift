//
//  MockOrderService.swift
//  E-commerceTests
//
//  Created by MacBook on 21/06/2025.
//

import Foundation
@testable import E_commerce

class MockOrderService: OrderServiceProtocol {

    var shouldReturnError = false
    
    let mockOrder = OrderModel(
        id: 1,
        adminGraphqlAPIID: "gid://shopify/Order/1",
        orderNumber: 1001,
        name: "Test Order",
        createdAt: Date(),
        processedAt: Date(),
        financialStatus: .paid,
        currency: .egp,
        totalPrice: "100.00",
        totalDiscounts: "0.00",
        subtotalPrice: "100.00",
        email: "test@example.com",
        contactEmail: "test@example.com",
        confirmationNumber: "ABC123",
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

    static var shared = MockOrderService()

    func createOrder(cartItems: [E_commerce.CartItem], customer: E_commerce.Customer, discountCode: String?, discountAmount: Double?, discountType: String, currency: String, completion: @escaping (Result<E_commerce.OrderResponse, any Error>) -> Void) {
        MockOrderService.shared.mockCreateOrder(completion: completion)
    }

     func getOrders(forEmail email: String, completion: @escaping (Result<[OrderModel], Error>) -> Void) {
         MockOrderService.shared.mockGetOrders(completion: completion)
    }

    private func mockCreateOrder(completion: @escaping (Result<OrderResponse, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Create order failed"])))
        } else {
            let response = OrderResponse(order: mockOrder)
            completion(.success(response))
        }
    }

    private func mockGetOrders(completion: @escaping (Result<[OrderModel], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Get orders failed"])))
        } else {
            completion(.success([mockOrder]))
        }
    }
}
