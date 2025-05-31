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
    let selectedVariant: Variant
    var quantity: Int
    
    var subtotal: Double {
        return Double(selectedVariant.price)! * Double(quantity)
        }
        
        // Helper to get color (usually option2 in Shopify)
        var color: String {
            return selectedVariant.option2 ?? selectedVariant.option1 ?? ""
        }
        
        // Helper to get size (usually option1 in Shopify)
        var size: String {
            return selectedVariant.option1 ?? ""
        }
}
