//
//  OrderService.swift
//  E-commerce
//
//  Created by MacBook on 12/06/2025.
//

import Foundation
import Alamofire

class OrderService {
    private let baseURL = "https://your-store.myshopify.com/admin/api/2025-04"
    private let accessToken = "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"
    
    func createOrder(order: ShopifyOrder, completion: @escaping (Result<ShopifyOrder, Error>) -> Void) {
        let endpoint = "\(baseURL)/orders.json"
        
        let parameters: [String: Any] = [
            "order": [
                "line_items": order.lineItems.map { item in
                    [
                        "variant_id": item.variantId,
                        "quantity": item.quantity,
                        "price": item.price
                    ]
                },
                "shipping_address": [
                    "address1": order.shippingAddress.address1,
                    "city": order.shippingAddress.city,
                    "country": order.shippingAddress.country
                ],
                "financial_status": order.financialStatus,
                "email": order.customer?.email ?? "",
                "customer": [
                    "first_name": order.customer?.firstName ?? "",
                    "last_name": order.customer?.lastName ?? ""
                ],
                "total_price": String(format: "%.2f", order.total) 
            ]
        ]
        
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": accessToken,
            "Content-Type": "application/json"
        ]
        
        AF.request(endpoint,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: OrderResponse.self) { response in
            switch response.result {
            case .success(let orderResponse):
                completion(.success(orderResponse.order))
            case .failure(let error):
                if let data = response.data,
                   let errorMessage = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Shopify API Error: \(errorMessage)")
                }
                completion(.failure(error))
            }
        }
    }
}

