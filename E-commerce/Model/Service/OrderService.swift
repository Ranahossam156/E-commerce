//
//  OrderService.swift
//  E-commerce
//
//  Created by MacBook on 12/06/2025.
//

import Foundation
import Alamofire

class OrderService {
    private let baseURL = "https://ios4-sv.myshopify.com/admin/api/2024-01/orders.json"
    private let accessToken = "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"
    
    private let session: Session = {
        #if targetEnvironment(simulator)
        let config = URLSessionConfiguration.ephemeral
        #else
        let config = URLSessionConfiguration.default
        #endif
        return Session(configuration: config)
    }()

    func createOrder(cartItems: [CartItem], customer: Customer, discountCode: String?,
                     discountAmount: Double?, discountType: String, currency: String, completion: @escaping (Result<OrderResponse, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": accessToken,
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        let payload = OrderPayload(cartItems: cartItems, customer: customer, discountCode: discountCode,
                                   discountAmount: discountAmount, discountType: discountType, currency: currency)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        session.request(baseURL,
                        method: .post,
                        parameters: payload,
                        encoder: JSONParameterEncoder.default,
                        headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: OrderResponse.self, decoder: decoder) { response in
                switch response.result {
                case .success(let orderResponse):
                    let orderId = orderResponse.order.id
                    print("Order ID: \(orderResponse.order.id)")
                    completion(.success(orderResponse))
                case .failure(let error):
                    if let data = response.data,
                       let responseBody = String(data: data, encoding: .utf8) {
                        print("Shopify response body:\n\(responseBody)")
                    }
                    completion(.failure(error))
                }
            }
    }
    
    func getOrders(forEmail email: String, completion: @escaping (Result<[OrderModel], Error>) -> Void) {
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": accessToken,
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        let params: Parameters = ["email": email]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        session.request(baseURL, method: .get, parameters: params, headers: headers)
            .validate()
            .responseDecodable(of: OrdersListResponse.self, decoder: decoder) { response in
                switch response.result {
                case .success(let result):
                    completion(.success(result.orders))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
