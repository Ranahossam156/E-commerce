//
//  CartItem.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    var subtotal: Double {
        return Double(product.price)! * Double(quantity)
    }
}
