//
//  CartItem.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation


struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    let selectedVariant: Variant
    var quantity: Int
    
    init(id: UUID = UUID(), product: Product, selectedVariant: Variant, quantity: Int) {
        self.id = id
        self.product = product
        self.selectedVariant = selectedVariant
        self.quantity = quantity
    }
}
