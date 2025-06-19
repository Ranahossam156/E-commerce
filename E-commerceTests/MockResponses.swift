//
//  MockResponses.swift
//  E-commerceTests
//
//  Created by Test on 02/06/2025.
//

import Foundation
@testable import E_commerce

struct MockResponses {
    
    // MARK: - Price Rules Mock Data
    static let validPriceRulesJSON = """
    {
        "price_rules": [
                {
                    "id": 1489809670441,
                    "value": "-10.0",
                    "title": "Summer Sale",
                },
                {
                    "id": 1489809277225,
                    "value_type": "percentage",
                    "value": "-10.0",
                    "title": "Summer Sale",
                },
                
            ]
    }
    """.data(using: .utf8)!
    
    static let emptyPriceRulesJSON = """
    {
        "price_rules": []
    }
    """.data(using: .utf8)!
    
    // MARK: - Discount Codes Mock Data
    static let validDiscountCodesJSON = """
    {
        "discount_codes": [
            {
                "id": 20510678778153,
                "price_rule_id": 1489809670441,
                "code": "SUMMER20",
                "usage_count": 0,
                "created_at": "2025-06-02T03:15:50-04:00",
                "updated_at": "2025-06-02T03:15:50-04:00"
            },
            {
                "id": 20495995666729,
                "price_rule_id": 1489809670441,
                "code": "SUMMER10",
                "usage_count": 0,
                "created_at": "2025-05-27T14:59:26-04:00",
                "updated_at": "2025-05-27T14:59:26-04:00"
            }
        ]
    }
    """.data(using: .utf8)!
    
    static let emptyDiscountCodesJSON = """
    {
        "discount_codes": []
    }
    """.data(using: .utf8)!
}
