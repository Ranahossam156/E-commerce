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
    
    // Add other properties as needed
}

import Foundation

struct Variant: Codable {
    let id: String
    let option1: String? // e.g., size
    let option2: String? // e.g., color
    let price: Double
    
    // Add other properties as needed
}