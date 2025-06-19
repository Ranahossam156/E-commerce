//
//  CartServiceProtocol.swift
//  E-commerce
//
//  Created by Kerolos on 19/06/2025.
//

import Foundation


public protocol CartServiceProtocol {
    func loadCartItems(for userId: String, completion: @escaping (Result<[CartItem], Error>) -> Void)
    func saveCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteCartItem(_ cartItem: CartItem, for userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func clearCart(for userId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

