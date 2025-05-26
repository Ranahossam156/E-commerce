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
    @Published var selectedItems: Set<UUID> = Set()
    
    init() {
        // Initialize with dummy data for now
        loadDummyData()
    }
    
    private func loadDummyData() {
        // Add dummy products to cart
        Product.dummyProducts.forEach { product in
            self.addToCart(product: product, quantity: 1)
        }
    }
    
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            let newItem = CartItem(product: product, quantity: quantity)
            cartItems.append(newItem)
        }
        calculateTotal()
    }
    
    func removeFromCart(productId: Int) {
        cartItems.removeAll(where: { $0.product.id == productId })
        calculateTotal()
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            let maxQuantity = item.product.inventory
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
        selectedItems.removeAll()
    }
    
    func toggleItemSelection(itemId: UUID) {
        if selectedItems.contains(itemId) {
            selectedItems.remove(itemId)
        } else {
            selectedItems.insert(itemId)
        }
    }
    
    func isItemSelected(itemId: UUID) -> Bool {
        return selectedItems.contains(itemId)
    }
    
    // For future API integration
    func loadProductsFromAPI() {
        // This will be implemented when connecting to the API
    }
}
