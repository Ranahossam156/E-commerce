//
//  OrderItem.swift
//  E-commerce
//
//  Created by MacBook on 12/06/2025.
//

import Foundation

struct OrderItem: Identifiable {
    let id = UUID()
    let name: String
    let color: String
    let quantity: Int
    let price: Double
    var status: String
    let imageName: String
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? ""
    }
}
