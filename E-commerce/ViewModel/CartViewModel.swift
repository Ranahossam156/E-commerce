//
//  CartViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation
import SwiftUI
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var total: Double = 0
    
    static let shared = CartViewModel()

    private init() {
            // Private init for singleton
        }

    
    func addToCart(product: Product, variant: Variant, quantity: Int = 1) {
          if let index = cartItems.firstIndex(where: { $0.selectedVariant.id == variant.id }) {
              cartItems[index].quantity += quantity
          } else {
              let newItem = CartItem(product: product, selectedVariant: variant, quantity: quantity)
              cartItems.append(newItem)
          }
          calculateTotal()
      }
    
    func removeFromCart(variantId: Int) {
            cartItems.removeAll(where: { $0.selectedVariant.id == variantId })
            calculateTotal()
        }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
          if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
              let maxQuantity = item.selectedVariant.inventoryQuantity
              cartItems[index].quantity = min(maxQuantity, max(1, quantity))
          }
          calculateTotal()
      }
    
    func calculateTotal() {
        total = cartItems.reduce(0) { $0 + $1.subtotal }
    }
    
    func clearCart() {
        cartItems.removeAll()
        total = 0
    }
    
    
    // For future API integration
    func loadProductsFromAPI() {
        // This will be implemented when connecting to the API
    }
}


