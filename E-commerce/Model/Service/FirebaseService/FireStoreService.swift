//  FirestoreService.swift
//  E-commerce
//
//  Created by Kerolos on 13/06/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirestoreService {
    private let db = Firestore.firestore()
    
    // MARK: - Cart Operations
    
    /// Loads cart items for the specified user from Firestore
    func loadCartItems(for userId: String, completion: @escaping (Result<[CartItem], Error>) -> Void) { // Changed: Added userId parameter
        db.collection("carts").document(userId).collection("items").getDocuments { snapshot, error in // Changed: Updated path to "carts/{userId}/items"
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let cartItems = snapshot?.documents.compactMap { document in
                try? document.data(as: CartItem.self)
            } ?? []
            completion(.success(cartItems))
        }
    }
    
    /// Saves a cart item to Firestore
    func saveCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) { // Changed: Added userId parameter
        do {
            try db.collection("carts").document(userId).collection("items").document(cartItem.id.uuidString).setData(from: cartItem) { error in // Changed: Updated path to "carts/{userId}/items"
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Updates a cart item in Firestore
    func updateCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) { // Changed: Added userId parameter
        saveCartItem(cartItem, for: userId, completion: completion) // Same as saving, as setData overwrites
    }
    
    /// Deletes a cart item from Firestore
    func deleteCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) { // Changed: Added userId parameter
        db.collection("carts").document(userId).collection("items").document(cartItem.id.uuidString).delete { error in // Changed: Updated path to "carts/{userId}/items"
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Clears all cart items for the specified user
    func clearCart(for userId: String, completion: @escaping (Result<Void, Error>) -> Void) { // Changed: Added userId parameter
        db.collection("carts").document(userId).collection("items").getDocuments { snapshot, error in // Changed: Updated path to "carts/{userId}/items"
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let batch = self.db.batch()
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

extension FirestoreService {
    // Future: Add methods for other collections (e.g., favorites, orders)
    func saveFavorite(_ favorite: FavoriteProductModel, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implementation for favorites
    }
}
