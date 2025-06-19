//
//  Product.swift
//  E-commerce
//
//  Created by Kerolos on 19/06/2025.
//


struct Product: Codable {
    let id: String
    let title: String
    let price: Double
    
}

import Foundation

struct Variant: Codable {
    let id: String
    let option1: String?
    let option2: String?
    let price: Double
    
}
