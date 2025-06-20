//  CartViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var total: Double = 0
    @Published var errorMessage: String? // Added for error feedback
    
    private let currencyService: CurrencyService
    private let firestoreService: CartFireStoreService
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    static let shared = CartViewModel(currencyService: CurrencyService(), firestoreService: CartFireStoreService())
    
    var selectedCurrency: String = "USD"
    
    init(currencyService: CurrencyService = CurrencyService(), firestoreService: CartFireStoreService = CartFireStoreService()) {
        self.currencyService = currencyService
        self.firestoreService = firestoreService
        print("CartViewModel initialized")
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.cartItems = []
            self.total = 0
            self.errorMessage = nil
            if let user = user {
                self.loadCartFromFirestore(for: user.uid)
            } else {
                print("No auth found")
            }
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func addToCart(product: Product, variant: Variant, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.selectedVariant.id == variant.id }) {
            cartItems[index].quantity += quantity
            if let userId = Auth.auth().currentUser?.uid {
                firestoreService.updateCartItem(cartItems[index], for: userId) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            print("Firebase cart item updated")
                        case .failure(let error):
                            print("Error updating cart item: \(error.localizedDescription)")
                            self?.errorMessage = "Failed to update cart: \(error.localizedDescription)"
                        }
                    }
                }
            }
        } else {
            let newItem = CartItem(id: UUID(), product: product, selectedVariant: variant, quantity: quantity)
            cartItems.append(newItem)
            if let userId = Auth.auth().currentUser?.uid {
                firestoreService.saveCartItem(newItem, for: userId) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            print("Cart item saved successfully")
                        case .failure(let error):
                            print("Error saving cart item: \(error.localizedDescription)")
                            self?.errorMessage = "Failed to save cart: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        calculateTotal()
    }
    
    func removeFromCart(variantId: Int) {
        if let item = cartItems.first(where: { $0.selectedVariant.id == variantId }) {
            cartItems.removeAll(where: { $0.selectedVariant.id == variantId })
            if let userId = Auth.auth().currentUser?.uid {
                firestoreService.deleteCartItem(item, for: userId) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            print("Cart item deleted successfully")
                        case .failure(let error):
                            print("Error deleting cart item: \(error.localizedDescription)")
                            self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        calculateTotal()
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            let maxQuantity = item.selectedVariant.inventoryQuantity > 0 ? item.selectedVariant.inventoryQuantity : 1
            cartItems[index].quantity = min(maxQuantity, max(1, quantity))
            if let userId = Auth.auth().currentUser?.uid {
                firestoreService.updateCartItem(cartItems[index], for: userId) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            print("Cart item quantity updated successfully")
                        case .failure(let error):
                            print("Error updating cart item quantity: \(error.localizedDescription)")
                            self?.errorMessage = "Failed to update quantity: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        calculateTotal()
    }
    
    func calculateTotal() {
        total = cartItems.reduce(0) { $0 + $1.subtotal }
        total = currencyService.convert(price: total)
        print("Total calculated: \(total)")
    }
    
    func clearCart() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, cannot clear cart")
            errorMessage = "No authenticated user"
            return
        }
        print("Clearing cart for user: \(userId)")
        firestoreService.clearCart(for: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.cartItems = []
                    self?.total = 0
                    self?.errorMessage = nil
                    print("Cart cleared successfully")
                case .failure(let error):
                    print("Error clearing cart: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to clear cart: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadCartFromFirestore(for userId: String) {
        firestoreService.loadCartItems(for: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.cartItems = items
                    self?.calculateTotal()
                    print("Cart loaded: \(items.count) items")
                case .failure(let error):
                    print("Error loading cart: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to load cart: \(error.localizedDescription)"
                }
            }
        }
    }
}
