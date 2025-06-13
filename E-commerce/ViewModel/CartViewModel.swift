//
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
    
    private let currencyService: CurrencyService
    private let firestoreService: FirestoreService
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    static let shared = CartViewModel(currencyService: CurrencyService() , firestoreService: FirestoreService())
    
    var selectedCurrency: String = "USD" // Default, update as needed
    
    init(currencyService: CurrencyService, firestoreService: FirestoreService) {
        self.currencyService = currencyService
        self.firestoreService = firestoreService
        print("CartViewModel initialized")
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.cartItems = []
            self.total = 0
            if user != nil {
                self.loadCartFromFirestore()
            }
            else {
                print ("no auth found ")
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
            firestoreService.updateCartItem(cartItems[index]) { result in
                switch result {
                case .success :
                    print ("firebase cart item updated ")
                
                case .failure :
                    print("Error updating cart item: ")                }
                
                
            }
            
        } else {
            let newItem = CartItem(product: product, selectedVariant: variant, quantity: quantity)
            cartItems.append(newItem)
            firestoreService.saveCartItem(newItem) { result in
                switch result {
                case .success:
                    print("Cart item saved successfully")
                case .failure(let error):
                    print("Error saving cart item: \(error.localizedDescription)")
                }
            }
        }
        calculateTotal()
    }
    
    func removeFromCart(variantId: Int) {
            if let item = cartItems.first(where: { $0.selectedVariant.id == variantId }) {
                cartItems.removeAll(where: { $0.selectedVariant.id == variantId })
                firestoreService.deleteCartItem(item) { result in
                    switch result {
                    case .success:
                        print("Cart item deleted successfully")
                    case .failure(let error):
                        print("Error deleting cart item: \(error.localizedDescription)")
                    }
                }
            }
            calculateTotal()
        }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                let maxQuantity = item.selectedVariant.inventoryQuantity
                cartItems[index].quantity = min(maxQuantity, max(1, quantity))
                firestoreService.updateCartItem(cartItems[index]) { result in
                    switch result {
                    case .success:
                        print("Cart item quantity updated successfully")
                    case .failure(let error):
                        print("Error updating cart item quantity: \(error.localizedDescription)")
                    }
                }
            }
            calculateTotal()
        }
    
    func calculateTotal() {
        total = cartItems.reduce(0) { $0 + $1.subtotal }
        total = currencyService.convert(price: total)
    }
    
    func clearCart() {
            firestoreService.clearCart { [weak self] result in
                switch result {
                case .success:
                    self?.cartItems.removeAll()
                    self?.total = 0
                    print("Cart cleared successfully")
                case .failure(let error):
                    print("Error clearing cart: \(error.localizedDescription)")
                }
            }
        }
    
    
    private func loadCartFromFirestore() {
            firestoreService.loadCartItems { [weak self] result in
                switch result {
                case .success(let items):
                    self?.cartItems = items
                    self?.calculateTotal()
                case .failure(let error):
                    print("Error loading cart: \(error.localizedDescription)")
                }
            }
        }
}


