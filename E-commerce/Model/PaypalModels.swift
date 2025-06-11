//
//  PaypalModels.swift
//  E-commerce
//
//  Created by Kerolos on 11/06/2025.
//

import Foundation

// MARK: - PayPal Models

struct PayPalCreateOrderRequest: Codable {
    let intent: String
    let purchaseUnits: [PayPalPurchaseUnit]
    
    enum CodingKeys: String, CodingKey {
        case intent
        case purchaseUnits = "purchase_units"
    }
}

struct PayPalPurchaseUnit: Codable {
    let amount: PayPalAmount
    let items: [PayPalItem]?
}

struct PayPalAmount: Codable {
    let currencyCode: String
    let value: String
    let breakdown: PayPalBreakdown?
    
    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case value
        case breakdown
    }
}

struct PayPalBreakdown: Codable {
    let itemTotal: PayPalItemTotal
    
    enum CodingKeys: String, CodingKey {
        case itemTotal = "item_total"
    }
}

struct PayPalItemTotal: Codable {
    let currencyCode: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case value
    }
}

struct PayPalItem: Codable {
    let name: String
    let unitAmount: PayPalUnitAmount
    let quantity: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case unitAmount = "unit_amount"
        case quantity
        case category
    }
}

struct PayPalUnitAmount: Codable {
    let currencyCode: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case value
    }
}

struct PayPalCreateOrderResponse: Codable {
    let id: String
    let status: String
    let links: [PayPalLink]
}

struct PayPalLink: Codable {
    let href: String
    let rel: String
    let method: String
}

struct PayPalAccessTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
