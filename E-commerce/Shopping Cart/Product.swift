//
//  Product.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation

struct Product: Identifiable {
    let id: Int
    let title: String
    let imageURL: String
    let color: String
    let price: String
    let inventory: Int
    
    //  dummy data
    static let dummyProducts = [
        Product(id: 1, title: "Bix Bag Limited Edition 229", imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image1.jpg", color: "Brown", price: "67.00", inventory: 10),
        
        Product(id: 1, title: "Bix Bag Limited Edition 229", imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image1.jpg", color: "Brown", price: "67.00", inventory: 10),
        
        Product(id: 2, title: "Bix Bag Limited Edition 229", imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_30_image1.jpg?v=1748176637", color: "Brown", price: "67.00", inventory: 10),
    ]
}
