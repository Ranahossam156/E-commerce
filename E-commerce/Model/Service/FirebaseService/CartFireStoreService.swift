//  FirestoreService.swift
//  E-commerce
//
//  Created by Kerolos on 13/06/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CartFireStoreService : CartServiceProtocol {
    private let db = Firestore.firestore()
    
    // MARK: - Cart Operations
    
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
    
    func saveCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("carts").document(userId).collection("items").document(cartItem.id.uuidString).setData(from: cartItem) { error in
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
    
    func updateCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        saveCartItem(cartItem, for: userId, completion: completion)
    }
    
    func deleteCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("carts").document(userId).collection("items").document(cartItem.id.uuidString).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func clearCart(for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("carts").document(userId).collection("items").getDocuments { snapshot, error in
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

