//
//  Order.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import Foundation

struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let itemCount: Int
    let address: String
    let amountPaid: Double
    let currency: String
    let date: Date
    var items: [OrderItem] = []
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amountPaid)) ?? ""
    }
}
