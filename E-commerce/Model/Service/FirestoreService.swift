//
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
    
    /// Loads cart items for the authenticated user from Firestore
    func loadCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("cart").getDocuments { snapshot, error in
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
    func saveCartItem(_ cartItem: CartItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        do {
            try db.collection("users").document(userId).collection("cart").document(cartItem.id.uuidString).setData(from: cartItem) { error in
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
    func updateCartItem(_ cartItem: CartItem, completion: @escaping (Result<Void, Error>) -> Void) {
        saveCartItem(cartItem, completion: completion) // Same as saving, as setData overwrites
    }
    
    /// Deletes a cart item from Firestore
    func deleteCartItem(_ cartItem: CartItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("cart").document(cartItem.id.uuidString).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Clears all cart items for the authenticated user
    func clearCart(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("cart").getDocuments { snapshot, error in
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
