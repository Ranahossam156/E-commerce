//
//  MockCartFirestoreService.swift
//  E-commerce
//
//  Created by Kerolos on 19/06/2025.
//

import Foundation

class MockCartFirestoreService: CartServiceProtocol {
    var cartItems: [String: [CartItem]] = [:] // userId: [CartItems]
    var shouldFail = false
    var delay: TimeInterval = 0
    
    func loadCartItems(for userId: String, completion: @escaping (Result<[CartItem], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if self.shouldFail {
                completion(.failure(NSError(domain: "MockError", code: -1, userInfo: nil)))
                return
            }
            
            let items = self.cartItems[userId] ?? []
            completion(.success(items))
        }
    }
    
    func saveCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Capture self strongly to prevent premature deallocation
        let strongSelf = self
        
        DispatchQueue.global().asyncAfter(deadline: .now() + strongSelf.delay) {
            // Check if we should simulate failure
            if strongSelf.shouldFail {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "MockError", code: -1, userInfo: nil)))
                }
                return
            }
            
            // Perform thread-safe access to cartItems
            var items = strongSelf.cartItems[userId] ?? []
            if let index = items.firstIndex(where: { $0.id == cartItem.id }) {
                items[index] = cartItem
            } else {
                items.append(cartItem)
            }
            
            // Thread-safe write
            DispatchQueue.main.async {
                strongSelf.cartItems[userId] = items
                completion(.success(()))
            }
        }
    }
    // Implement other protocol methods similarly...
    func updateCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        saveCartItem(cartItem, for: userId, completion: completion)
    }
    
    func deleteCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if self.shouldFail {
                completion(.failure(NSError(domain: "MockError", code: -1, userInfo: nil)))
                return
            }
            
            var items = self.cartItems[userId] ?? []
            items.removeAll { $0.id == cartItem.id }
            self.cartItems[userId] = items
            completion(.success(()))
        }
    }
    
    func clearCart(for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if self.shouldFail {
                completion(.failure(NSError(domain: "MockError", code: -1, userInfo: nil)))
                return
            }
            
            self.cartItems[userId] = []
            completion(.success(()))
        }
    }
}
