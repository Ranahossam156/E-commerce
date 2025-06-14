//
//  Coupons.swift
//  E-commerce
//
//  Created by Kerolos on 02/06/2025.
//

import Foundation

struct PriceRulesResponse: Codable {
    let priceRules: [PriceRule]
    
    enum CodingKeys: String, CodingKey {
        case priceRules = "price_rules"
    }
}

struct PriceRule: Codable, Identifiable {
    let id: Int
    let valueType: String
    let value: String
    let customerSelection: String
    let targetType: String
    let targetSelection: String
    let allocationMethod: String
    let allocationLimit: Int?
    let oncePerCustomer: Bool
    let usageLimit: Int?
    let startsAt: String
    let endsAt: String?
    let createdAt: String
    let updatedAt: String
    let title: String
    let adminGraphqlAPIID: String
    
    // Add this property to store fetched discount code
    var discountCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case valueType = "value_type"
        case value
        case customerSelection = "customer_selection"
        case targetType = "target_type"
        case targetSelection = "target_selection"
        case allocationMethod = "allocation_method"
        case allocationLimit = "allocation_limit"
        case oncePerCustomer = "once_per_customer"
        case usageLimit = "usage_limit"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case title
        case adminGraphqlAPIID = "admin_graphql_api_id"
    }
    
    // Helper computed properties
    var discountDescription: String {
        if valueType == "percentage" {
            let percentage = abs(Double(value) ?? 0)
            return "\(Int(percentage))% OFF"
        } else {
            let amount = abs(Double(value) ?? 0)
            return "$\(Int(amount)) OFF"
        }
    }
    
    // Use fetched code if available, otherwise use hardcoded
    var couponCode: String {
        if let discountCode = discountCode {
            return discountCode
        }
        
        // Fallback to hardcoded codes
        switch id {
        case 1489809670441: return "SUMMER20"
        case 1489809277225: return "SUMMER10"
        case 1489807900969: return "WELCOME10"
        case 1489535861033: return "SAVE10"
        case 1489532354857: return "ORDER10"
        default: return title.uppercased().replacingOccurrences(of: " ", with: "")
        }
    }
}

// Add DiscountCode models
struct DiscountCodesResponse: Codable {
    let discountCodes: [DiscountCode]
    
    enum CodingKeys: String, CodingKey {
        case discountCodes = "discount_codes"
    }
}

struct DiscountCode: Codable {
    let id: Int
    let priceRuleId: Int
    let code: String
    let usageCount: Int
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case priceRuleId = "price_rule_id"
        case code
        case usageCount = "usage_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
