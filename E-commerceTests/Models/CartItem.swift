//
//  CartItem.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation


public struct CartItem: Identifiable, Codable {
    public let id: UUID
    let product: Product
    let selectedVariant: Variant
    var quantity: Int
    let stock: Int // New property for available stock
    
    init(id: UUID = UUID(), product: Product, selectedVariant: Variant, quantity: Int , stock : Int) {
        self.id = id
        self.product = product
        self.selectedVariant = selectedVariant
        self.quantity = quantity
        self.stock = stock
        
    }
}
