//
//  OrderServiceMock.swift
//  E-commerceTests
//

import Foundation
@testable import E_commerce

final class OrderServiceMock: OrderServiceProtocol {
    static var shouldReturnError = false
    static var mockCreateOrderResponse: OrderResponse?
    static var mockGetOrdersResponse: [OrderModel]?

    func createOrder(cartItems: [E_commerce.CartItem], customer: Customer, discountCode: String?, discountAmount: Double?, discountType: String, currency: String, completion: @escaping (Result<OrderResponse, Error>) -> Void) {
        if Self.shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else if let response = Self.mockCreateOrderResponse {
            completion(.success(response))
        }
    }

    func getOrders(forEmail email: String, completion: @escaping (Result<[OrderModel], Error>) -> Void) {
        if Self.shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 2, userInfo: nil)))
        } else if let response = Self.mockGetOrdersResponse {
            completion(.success(response))
        }
    }
}
