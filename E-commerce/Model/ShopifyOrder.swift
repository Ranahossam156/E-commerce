//
//  Order.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import Foundation

struct OrderResponse: Codable {
    let order: ShopifyOrder
}

struct ShopifyOrder: Identifiable, Codable {
    let id = UUID()
    let orderNumber: String
    let lineItems: [LineItem]
    let customer: Customer?
    let shippingAddress: ShippingAddress
    let financialStatus: String = "pending"
    let total: Double

    enum CodingKeys: String, CodingKey {
        case orderNumber = "order_number"
        case lineItems = "line_items"
        case customer
        case shippingAddress = "shipping_address"
        case financialStatus = "financial_status"
        case total = "total_price"

    }

    //    var formattedDate: String {
    //        let formatter = DateFormatter()
    //        formatter.dateStyle = .medium
    //        formatter.timeStyle = .short
    //        return formatter.string(from: date)
    //    }
    //
    //    var formattedAmount: String {
    //        let formatter = NumberFormatter()
    //        formatter.numberStyle = .currency
    //        formatter.currencyCode = currency
    //        return formatter.string(from: NSNumber(value: amountPaid)) ?? ""
    //    }
}
