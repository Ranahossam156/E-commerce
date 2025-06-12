//
//  Address.swift
//  E-commerce
//
//  Created by MacBook on 12/06/2025.
//

import Foundation
struct ShippingAddress: Codable {
    let address1: String
    let city: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case address1
        case city
        case country
    }
}
