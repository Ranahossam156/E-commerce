//
//  Promotion.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import Foundation
import SwiftUI


struct Promotion: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let image: String
    let discountCode: String?
    let valueType: String?
    let value: String?
    
    // Initialize from PriceRule
    init(from priceRule: PriceRule) {
        self.id = String(priceRule.id)
        self.title = priceRule.title
        self.subtitle = "Valid until \(Self.formatDate(priceRule.endsAt ?? ""))"
        self.image = "promo1" // You can customize this based on discount type
        self.discountCode = priceRule.title // Assuming title contains the code
        self.valueType = priceRule.valueType
        self.value = priceRule.value
    }
    
    // For preview/mock data
    init(title: String, subtitle: String, image: String, discountCode: String? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.discountCode = discountCode
        self.valueType = nil
        self.value = nil
    }
    
    private static func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return "Limited time"
    }
}
