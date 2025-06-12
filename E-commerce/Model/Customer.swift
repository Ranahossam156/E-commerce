//
//  Customer.swift
//  E-commerce
//
//  Created by MacBook on 12/06/2025.
//

import Foundation

struct Customer: Codable {
    let email: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
