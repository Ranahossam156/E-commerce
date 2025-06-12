//
//  OrderItem.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import Foundation

struct LineItem: Codable {
    let variantId: Int64
    let quantity: Int
    let price: String

    enum CodingKeys: String, CodingKey {
        case variantId = "variant_id"
        case quantity
        case price
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        if let priceDouble = Double(price) {
            return formatter.string(from: NSNumber(value: priceDouble)) ?? ""
        } else {
            return "$0.00"
        }
    }
}
